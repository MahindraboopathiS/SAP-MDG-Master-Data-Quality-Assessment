CLASS ZCL_MDQ_SCORING_ENGINE_TEST DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO ZIF_MDQ_SCORING_ENGINE.
    DATA mt_rules  TYPE ZIF_MDQ_CONSTANTS=>tt_rules.

    METHODS setup.
    METHODS test_perfect_score       FOR TESTING.
    METHODS test_deduction_score     FOR TESTING.
    METHODS test_rating_band_derivation FOR TESTING.
ENDCLASS.

CLASS ZCL_MDQ_SCORING_ENGINE_TEST IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT mo_engine TYPE ZCL_MDQ_SCORING_ENGINE.

    mt_rules = VALUE #(
      ( rule_id = 'FR-001' weight = 25 )
      ( rule_id = 'FR-002' weight = 25 )
      ( rule_id = 'FR-003' weight = 15 )
    ).
  ENDMETHOD.

  METHOD test_perfect_score.
    DATA lt_findings TYPE ZIF_MDQ_CONSTANTS=>tt_findings.

    DATA(ls_result) = mo_engine->calculate_score(
      iv_object_type = 'MAT'
      iv_object_key  = '1001'
      it_findings    = lt_findings
      it_rules       = mt_rules
    ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-score
      exp = 100
      msg = 'Record with zero findings should receive score of 100'
    ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-rating_band
      exp = ZIF_MDQ_CONSTANTS=>gc_band_excellent
      msg = 'Score 100 must be classified as EXCELLENT'
    ).
  ENDMETHOD.

  METHOD test_deduction_score.
    DATA lt_findings TYPE ZIF_MDQ_CONSTANTS=>tt_findings.

    APPEND VALUE #( object_type = 'MAT' object_key = '1002' rule_id = 'FR-001' severity = 'CRITICAL' ) TO lt_findings.
    APPEND VALUE #( object_type = 'MAT' object_key = '1002' rule_id = 'FR-003' severity = 'HIGH' ) TO lt_findings.

    DATA(ls_result) = mo_engine->calculate_score(
      iv_object_type = 'MAT'
      iv_object_key  = '1002'
      it_findings    = lt_findings
      it_rules       = mt_rules
    ).

    " Score = 100 - (25 + 15) = 60
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-score
      exp = 60
      msg = 'Record with 40 points deduction should score 60'
    ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-rating_band
      exp = ZIF_MDQ_CONSTANTS=>gc_band_poor
      msg = 'Score 60 must be classified as POOR'
    ).
  ENDMETHOD.

  METHOD test_rating_band_derivation.
    cl_abap_unit_assert=>assert_equals( act = mo_engine->derive_rating_band( 98 ) exp = 'EXCELLENT' ).
    cl_abap_unit_assert=>assert_equals( act = mo_engine->derive_rating_band( 88 ) exp = 'GOOD' ).
    cl_abap_unit_assert=>assert_equals( act = mo_engine->derive_rating_band( 75 ) exp = 'FAIR' ).
    cl_abap_unit_assert=>assert_equals( act = mo_engine->derive_rating_band( 55 ) exp = 'POOR' ).
    cl_abap_unit_assert=>assert_equals( act = mo_engine->derive_rating_band( 30 ) exp = 'CRITICAL' ).
  ENDMETHOD.

ENDCLASS.
