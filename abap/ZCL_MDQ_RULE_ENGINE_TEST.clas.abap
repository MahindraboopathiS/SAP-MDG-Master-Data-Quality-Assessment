CLASS ZCL_MDQ_RULE_ENGINE_TEST DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_repo   TYPE REF TO ZIF_MDQ_REPOSITORY.
    DATA mo_engine TYPE REF TO ZIF_MDQ_RULE_ENGINE.

    METHODS setup.
    METHODS test_evaluate_materials FOR TESTING.
    METHODS test_evaluate_customers FOR TESTING.
    METHODS test_evaluate_vendors   FOR TESTING.
ENDCLASS.

CLASS ZCL_MDQ_RULE_ENGINE_TEST IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT mo_repo TYPE ZCL_MDQ_REPO_MOCK.
    CREATE OBJECT mo_engine TYPE ZCL_MDQ_RULE_ENGINE.
  ENDMETHOD.

  METHOD test_evaluate_materials.
    DATA(lt_findings) = mo_engine->evaluate_materials( mo_repo ).
    
    cl_abap_unit_assert=>assert_not_initial(
      act = lines( lt_findings )
      msg = 'Rule engine should detect quality issues in mock materials'
    ).

    " Check FR-001 finding for material 000000000000001002
    READ TABLE lt_findings INTO DATA(ls_finding) WITH KEY rule_id = 'FR-001' object_key = '000000000000001002'.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'FR-001 (missing description) should be detected for material 1002'
    ).
  ENDMETHOD.

  METHOD test_evaluate_customers.
    DATA(lt_findings) = mo_engine->evaluate_customers( mo_repo ).
    
    cl_abap_unit_assert=>assert_not_initial(
      act = lines( lt_findings )
      msg = 'Rule engine should detect quality issues in mock customers'
    ).

    " Check FR-011 finding for customer 0000100002
    READ TABLE lt_findings INTO DATA(ls_finding) WITH KEY rule_id = 'FR-011' object_key = '0000100002'.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'FR-011 (missing name) should be detected for customer 100002'
    ).
  ENDMETHOD.

  METHOD test_evaluate_vendors.
    DATA(lt_findings) = mo_engine->evaluate_vendors( mo_repo ).
    
    cl_abap_unit_assert=>assert_not_initial(
      act = lines( lt_findings )
      msg = 'Rule engine should detect quality issues in mock vendors'
    ).

    " Check FR-021 finding for vendor 0000200002
    READ TABLE lt_findings INTO DATA(ls_finding) WITH KEY rule_id = 'FR-021' object_key = '0000200002'.
    cl_abap_unit_assert=>assert_subrc(
      act = sy-subrc
      msg = 'FR-021 (missing Tax ID) should be detected for vendor 200002'
    ).
  ENDMETHOD.

ENDCLASS.
