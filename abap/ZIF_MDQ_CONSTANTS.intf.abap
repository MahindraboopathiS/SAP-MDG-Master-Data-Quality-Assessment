INTERFACE ZIF_MDQ_CONSTANTS
  PUBLIC.

  " Business Object Types
  CONSTANTS:
    gc_obj_material TYPE string VALUE 'MAT',
    gc_obj_customer TYPE string VALUE 'CUST',
    gc_obj_vendor   TYPE string VALUE 'VEND',
    gc_obj_bp       TYPE string VALUE 'BP'.

  " Quality Rule Severities
  CONSTANTS:
    gc_sev_critical TYPE string VALUE 'CRITICAL',
    gc_sev_high     TYPE string VALUE 'HIGH',
    gc_sev_medium   TYPE string VALUE 'MEDIUM',
    gc_sev_low      TYPE string VALUE 'LOW'.

  " Scoring Band Classifications
  CONSTANTS:
    gc_band_excellent TYPE string VALUE 'EXCELLENT',
    gc_band_good      TYPE string VALUE 'GOOD',
    gc_band_fair      TYPE string VALUE 'FAIR',
    gc_band_poor      TYPE string VALUE 'POOR',
    gc_band_critical  TYPE string VALUE 'CRITICAL'.

  " Types definitions
  TYPES:
    BEGIN OF ty_rule,
      rule_id     TYPE string,
      object_type TYPE string,
      field_name  TYPE string,
      description TYPE string,
      severity    TYPE string,
      weight      TYPE i,
      is_active   TYPE abap_bool,
    END OF ty_rule,
    tt_rules TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_finding,
      execution_id TYPE string,
      object_type  TYPE string,
      object_key   TYPE string,
      rule_id      TYPE string,
      severity     TYPE string,
      field_name   TYPE string,
      message      TYPE string,
    END OF ty_finding,
    tt_findings TYPE STANDARD TABLE OF ty_finding WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_duplicate_finding,
      object_type  TYPE string,
      primary_key  TYPE string,
      match_key    TYPE string,
      similarity   TYPE p DECIMALS 2,
      match_type   TYPE string,
      details      TYPE string,
    END OF ty_duplicate_finding,
    tt_duplicate_findings TYPE STANDARD TABLE OF ty_duplicate_finding WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_score_result,
      object_type  TYPE string,
      object_key   TYPE string,
      score        TYPE p DECIMALS 2,
      rating_band  TYPE string,
      findings     TT_FINDINGS,
    END OF ty_score_result,
    tt_score_results TYPE STANDARD TABLE OF ty_score_result WITH DEFAULT KEY.

ENDINTERFACE.
