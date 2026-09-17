CLASS ZCL_MDQ_SCORING_ENGINE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES ZIF_MDQ_SCORING_ENGINE.

ENDCLASS.

CLASS ZCL_MDQ_SCORING_ENGINE IMPLEMENTATION.

  METHOD ZIF_MDQ_SCORING_ENGINE~calculate_score.
    rs_score-object_type = iv_object_type.
    rs_score-object_key  = iv_object_key.

    DATA: lv_total_weight    TYPE i VALUE 0,
          lv_deducted_points TYPE i VALUE 0.

    " Gather all findings related to this specific record key
    LOOP AT it_findings INTO DATA(ls_finding) WHERE object_type = iv_object_type AND object_key = iv_object_key.
      APPEND ls_finding TO rs_score-findings.

      READ TABLE it_rules INTO DATA(ls_rule) WITH KEY rule_id = ls_finding-rule_id.
      IF sy-subrc = 0.
        lv_deducted_points = lv_deducted_points + ls_rule-weight.
      ELSE.
        lv_deducted_points = lv_deducted_points + 10. " Default fallback weight
      ENDIF.
    ENDLOOP.

    " Total base weight for evaluation per record is 100
    lv_total_weight = 100.

    IF lv_deducted_points >= lv_total_weight.
      rs_score-score = 0.
    ELSE.
      rs_score-score = lv_total_weight - lv_deducted_points.
    ENDIF.

    rs_score-rating_band = me->ZIF_MDQ_SCORING_ENGINE~derive_rating_band( rs_score-score ).
  ENDMETHOD.

  METHOD ZIF_MDQ_SCORING_ENGINE~derive_rating_band.
    IF iv_score >= 95.
      rv_band = ZIF_MDQ_CONSTANTS=>gc_band_excellent.
    ELSEIF iv_score >= 85.
      rv_band = ZIF_MDQ_CONSTANTS=>gc_band_good.
    ELSEIF iv_score >= 70.
      rv_band = ZIF_MDQ_CONSTANTS=>gc_band_fair.
    ELSEIF iv_score >= 50.
      rv_band = ZIF_MDQ_CONSTANTS=>gc_band_poor.
    ELSE.
      rv_band = ZIF_MDQ_CONSTANTS=>gc_band_critical.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
