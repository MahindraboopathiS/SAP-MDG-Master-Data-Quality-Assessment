CLASS CX_MDQ_QUALITY_ERROR DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_rule_id TYPE string.
    DATA mv_message TYPE string.

    METHODS constructor
      IMPORTING
        textid   LIKE textid OPTIONAL
        previous LIKE previous OPTIONAL
        iv_rule_id TYPE string OPTIONAL
        iv_message TYPE string OPTIONAL.

ENDCLASS.

CLASS CX_MDQ_QUALITY_ERROR IMPLEMENTATION.

  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        textid   = textid
        previous = previous.
    me->mv_rule_id = iv_rule_id.
    me->mv_message = iv_message.
  ENDMETHOD.

ENDCLASS.
