INTERFACE ZIF_MDQ_SCORING_ENGINE
  PUBLIC.

  METHODS calculate_score
    IMPORTING
      iv_object_type   TYPE string
      iv_object_key    TYPE string
      it_findings      TYPE ZIF_MDQ_CONSTANTS=>tt_findings
      it_rules         TYPE ZIF_MDQ_CONSTANTS=>tt_rules
    RETURNING
      VALUE(rs_score)  TYPE ZIF_MDQ_CONSTANTS=>ty_score_result.

  METHODS derive_rating_band
    IMPORTING
      iv_score        TYPE p
    RETURNING
      VALUE(rv_band)  TYPE string.

ENDINTERFACE.
