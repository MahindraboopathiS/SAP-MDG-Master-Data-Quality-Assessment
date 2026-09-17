CLASS ZCL_MDQ_DUPLICATE_ENGINE_TEST DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_repo   TYPE REF TO ZIF_MDQ_REPOSITORY.
    DATA mo_engine TYPE REF TO ZCL_MDQ_DUPLICATE_ENGINE.

    METHODS setup.
    METHODS test_levenshtein_distance  FOR TESTING.
    METHODS test_similarity_calculation FOR TESTING.
    METHODS test_exact_tax_id_duplicates FOR TESTING.
    METHODS test_fuzzy_name_duplicates   FOR TESTING.
ENDCLASS.

CLASS ZCL_MDQ_DUPLICATE_ENGINE_TEST IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT mo_repo TYPE ZCL_MDQ_REPO_MOCK.
    CREATE OBJECT mo_engine TYPE ZCL_MDQ_DUPLICATE_ENGINE.
  ENDMETHOD.

  METHOD test_levenshtein_distance.
    " Test exact match -> distance 0
    cl_abap_unit_assert=>assert_equals(
      act = mo_engine->calculate_levenshtein( iv_str1 = 'ACME' iv_str2 = 'ACME' )
      exp = 0
      msg = 'Distance between identical strings must be 0'
    ).

    " Test 1 deletion/insertion -> distance 1
    cl_abap_unit_assert=>assert_equals(
      act = mo_engine->calculate_levenshtein( iv_str1 = 'ACME' iv_str2 = 'ACM' )
      exp = 1
      msg = 'Distance between ACME and ACM must be 1'
    ).

    " Test substitution -> distance 1
    cl_abap_unit_assert=>assert_equals(
      act = mo_engine->calculate_levenshtein( iv_str1 = 'ACME' iv_str2 = 'AKME' )
      exp = 1
      msg = 'Distance between ACME and AKME must be 1'
    ).
  ENDMETHOD.

  METHOD test_similarity_calculation.
    " Test exact match -> 100%
    DATA(lv_sim1) = mo_engine->calculate_similarity( iv_str1 = 'ACME Corporation' iv_str2 = 'ACME Corporation' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sim1
      exp = '100.00'
      msg = 'Similarity of identical strings must be 100%'
    ).

    " Test minor typo match -> high percentage
    DATA(lv_sim2) = mo_engine->calculate_similarity( iv_str1 = 'ACME Corporation' iv_str2 = 'ACME Corporacion' ).
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lv_sim2 >= '85.00' )
      msg = 'Minor typo similarity must be >= 85%'
    ).
  ENDMETHOD.

  METHOD test_exact_tax_id_duplicates.
    DATA(lt_dups) = mo_engine->ZIF_MDQ_DUPLICATE_ENGINE~detect_duplicate_customers( mo_repo ).
    
    cl_abap_unit_assert=>assert_not_initial(
      act = lines( lt_dups )
      msg = 'Duplicate engine should detect Tax ID duplicates in mock customers'
    ).

    READ TABLE lt_dups INTO DATA(ls_dup) WITH KEY match_type = 'EXACT_TAX_ID'.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'EXACT_TAX_ID match should be found between mock customer 100001 and 100003'
    ).
  ENDMETHOD.

  METHOD test_fuzzy_name_duplicates.
    DATA(lt_dups) = mo_engine->ZIF_MDQ_DUPLICATE_ENGINE~detect_duplicate_customers( mo_repo ).

    READ TABLE lt_dups INTO DATA(ls_dup) WITH KEY match_type = 'FUZZY_NAME'.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'FUZZY_NAME match should be found for customers with similar names'
    ).
  ENDMETHOD.

ENDCLASS.
