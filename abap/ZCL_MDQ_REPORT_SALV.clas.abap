CLASS ZCL_MDQ_REPORT_SALV DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_salv_row,
        object_type  TYPE string,
        object_key   TYPE string,
        score        TYPE p DECIMALS 2,
        rating_band  TYPE string,
        rule_id      TYPE string,
        severity     TYPE string,
        field_name   TYPE string,
        message      TYPE string,
        color_code   TYPE string,
      END OF ty_salv_row,
      tt_salv_rows TYPE STANDARD TABLE OF ty_salv_row WITH DEFAULT KEY.

    METHODS display_salv_grid
      IMPORTING
        it_scores TYPE ZIF_MDQ_CONSTANTS=>tt_score_results.

    METHODS prepare_salv_table
      IMPORTING
        it_scores     TYPE ZIF_MDQ_CONSTANTS=>tt_score_results
      RETURNING
        VALUE(rt_rows) TYPE tt_salv_rows.

  PRIVATE SECTION.
    METHODS derive_color_code
      IMPORTING
        iv_severity     TYPE string
        iv_rating       TYPE string
      RETURNING
        VALUE(rv_color) TYPE string.
ENDCLASS.

CLASS ZCL_MDQ_REPORT_SALV IMPLEMENTATION.

  METHOD derive_color_code.
    " Color codes for SAP SALV / ALV conditional formatting
    IF iv_severity = ZIF_MDQ_CONSTANTS=>gc_sev_critical OR iv_rating = ZIF_MDQ_CONSTANTS=>gc_band_critical.
      rv_color = 'C600'. " Red
    ELSEIF iv_severity = ZIF_MDQ_CONSTANTS=>gc_sev_high OR iv_rating = ZIF_MDQ_CONSTANTS=>gc_band_poor.
      rv_color = 'C500'. " Orange / Red
    ELSEIF iv_severity = ZIF_MDQ_CONSTANTS=>gc_sev_medium OR iv_rating = ZIF_MDQ_CONSTANTS=>gc_band_fair.
      rv_color = 'C300'. " Yellow
    ELSE.
      rv_color = 'C510'. " Green
    ENDIF.
  ENDMETHOD.

  METHOD prepare_salv_table.
    LOOP AT it_scores INTO DATA(ls_score).
      IF lines( ls_score-findings ) = 0.
        APPEND VALUE ty_salv_row(
          object_type = ls_score-object_type
          object_key  = ls_score-object_key
          score       = ls_score-score
          rating_band = ls_score-rating_band
          rule_id     = 'NONE'
          severity    = 'OK'
          field_name  = '-'
          message     = 'No quality findings detected'
          color_code  = me->derive_color_code( iv_severity = 'OK' iv_rating = ls_score-rating_band )
        ) TO rt_rows.
      ELSE.
        LOOP AT ls_score-findings INTO DATA(ls_finding).
          APPEND VALUE ty_salv_row(
            object_type = ls_score-object_type
            object_key  = ls_score-object_key
            score       = ls_score-score
            rating_band = ls_score-rating_band
            rule_id     = ls_finding-rule_id
            severity    = ls_finding-severity
            field_name  = ls_finding-field_name
            message     = ls_finding-message
            color_code  = me->derive_color_code( iv_severity = ls_finding-severity iv_rating = ls_score-rating_band )
          ) TO rt_rows.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD display_salv_grid.
    DATA(lt_rows) = me->prepare_salv_table( it_scores ).

    " In live SAP GUI environment:
    " cl_salv_table=>factory( IMPORTING r_salv_table = lo_salv CHANGING t_table = lt_rows ).
    " lo_salv->get_functions( )->set_default( abap_true ).
    " lo_salv->get_columns( )->set_optimize( abap_true ).
    " lo_salv->display( ).
  ENDMETHOD.

ENDCLASS.
