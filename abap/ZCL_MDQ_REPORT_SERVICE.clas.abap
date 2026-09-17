CLASS ZCL_MDQ_REPORT_SERVICE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_execution_summary,
        execution_id     TYPE string,
        timestamp        TYPE string,
        materials_eval   TYPE i,
        customers_eval   TYPE i,
        vendors_eval     TYPE i,
        total_findings   TYPE i,
        total_duplicates TYPE i,
        global_score     TYPE p DECIMALS 2,
        global_rating    TYPE string,
      END OF ty_execution_summary.

    METHODS constructor
      IMPORTING
        io_repo   TYPE REF TO ZIF_MDQ_REPOSITORY OPTIONAL
        io_engine TYPE REF TO ZIF_MDQ_RULE_ENGINE OPTIONAL.

    METHODS execute_full_audit
      RETURNING
        VALUE(rs_summary) TYPE ty_execution_summary.

    METHODS get_score_results
      RETURNING
        VALUE(rt_scores) TYPE ZIF_MDQ_CONSTANTS=>tt_score_results.

    METHODS get_duplicates
      RETURNING
        VALUE(rt_duplicates) TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings.

  PRIVATE SECTION.
    DATA mo_repo      TYPE REF TO ZIF_MDQ_REPOSITORY.
    DATA mo_rule_eng  TYPE REF TO ZIF_MDQ_RULE_ENGINE.
    DATA mo_score_eng TYPE REF TO ZIF_MDQ_SCORING_ENGINE.
    DATA mo_dupl_eng  TYPE REF TO ZIF_MDQ_DUPLICATE_ENGINE.
    DATA mo_auth_svc  TYPE REF TO ZCL_MDQ_AUTH_SERVICE.

    DATA mt_scores     TYPE ZIF_MDQ_CONSTANTS=>tt_score_results.
    DATA mt_duplicates TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings.
ENDCLASS.

CLASS ZCL_MDQ_REPORT_SERVICE IMPLEMENTATION.

  METHOD constructor.
    IF io_repo IS BOUND.
      mo_repo = io_repo.
    ELSE.
      CREATE OBJECT mo_repo TYPE ZCL_MDQ_REPO_MOCK.
    ENDIF.

    IF io_engine IS BOUND.
      mo_rule_eng = io_engine.
    ELSE.
      CREATE OBJECT mo_rule_eng TYPE ZCL_MDQ_RULE_ENGINE.
    ENDIF.

    CREATE OBJECT mo_score_eng TYPE ZCL_MDQ_SCORING_ENGINE.
    CREATE OBJECT mo_dupl_eng  TYPE ZCL_MDQ_DUPLICATE_ENGINE.
    CREATE OBJECT mo_auth_svc  TYPE ZCL_MDQ_AUTH_SERVICE.
  ENDMETHOD.

  METHOD execute_full_audit.
    CLEAR mt_scores.
    CLEAR mt_duplicates.

    " 1. Authorization check
    IF mo_auth_svc->check_material_authorization( ) = abap_false.
      " Exit if not authorized
      RETURN.
    ENDIF.

    DATA(lt_rules) = mo_repo->get_active_rules( ).

    " 2. Evaluate Materials
    DATA(lt_mat_findings) = mo_rule_eng->evaluate_materials( mo_repo ).
    DATA(lr_mat_ref) = mo_repo->get_material_master( ).
    FIELD-SYMBOLS <lt_mats> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_materials.
    ASSIGN lr_mat_ref->* TO <lt_mats>.
    IF <lt_mats> IS ASSIGNED.
      rs_summary-materials_eval = lines( <lt_mats> ).
      LOOP AT <lt_mats> ASSIGNING FIELD-SYMBOL(<ls_m>).
        DATA(ls_mat_score) = mo_score_eng->calculate_score(
          iv_object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          iv_object_key  = <ls_m>-matnr
          it_findings    = lt_mat_findings
          it_rules       = lt_rules
        ).
        APPEND ls_mat_score TO mt_scores.
      ENDLOOP.
    ENDIF.

    " 3. Evaluate Customers
    DATA(lt_cust_findings) = mo_rule_eng->evaluate_customers( mo_repo ).
    DATA(lr_cust_ref) = mo_repo->get_customer_master( ).
    FIELD-SYMBOLS <lt_custs> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_customers.
    ASSIGN lr_cust_ref->* TO <lt_custs>.
    IF <lt_custs> IS ASSIGNED.
      rs_summary-customers_eval = lines( <lt_custs> ).
      LOOP AT <lt_custs> ASSIGNING FIELD-SYMBOL(<ls_c>).
        DATA(ls_cust_score) = mo_score_eng->calculate_score(
          iv_object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          iv_object_key  = <ls_c>-kunnr
          it_findings    = lt_cust_findings
          it_rules       = lt_rules
        ).
        APPEND ls_cust_score TO mt_scores.
      ENDLOOP.
    ENDIF.

    " 4. Evaluate Vendors
    DATA(lt_vend_findings) = mo_rule_eng->evaluate_vendors( mo_repo ).
    DATA(lr_vend_ref) = mo_repo->get_vendor_master( ).
    FIELD-SYMBOLS <lt_vends> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_vendors.
    ASSIGN lr_vend_ref->* TO <lt_vends>.
    IF <lt_vends> IS ASSIGNED.
      rs_summary-vendors_eval = lines( <lt_vends> ).
      LOOP AT <lt_vends> ASSIGNING FIELD-SYMBOL(<ls_v>).
        DATA(ls_vend_score) = mo_score_eng->calculate_score(
          iv_object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          iv_object_key  = <ls_v>-lifnr
          it_findings    = lt_vend_findings
          it_rules       = lt_rules
        ).
        APPEND ls_vend_score TO mt_scores.
      ENDLOOP.
    ENDIF.

    " 5. Detect Duplicates
    DATA(lt_mat_dups)  = mo_dupl_eng->detect_duplicate_materials( mo_repo ).
    DATA(lt_cust_dups) = mo_dupl_eng->detect_duplicate_customers( mo_repo ).
    DATA(lt_vend_dups) = mo_dupl_eng->detect_duplicate_vendors( mo_repo ).
    APPEND LINES OF lt_mat_dups  TO mt_duplicates.
    APPEND LINES OF lt_cust_dups TO mt_duplicates.
    APPEND LINES OF lt_vend_dups TO mt_duplicates.

    " 6. Compute Global Aggregates
    rs_summary-execution_id     = 'EXEC-2026-0729-001'.
    rs_summary-timestamp        = '2026-07-29T10:20:00'.
    rs_summary-total_findings   = lines( lt_mat_findings ) + lines( lt_cust_findings ) + lines( lt_vend_findings ).
    rs_summary-total_duplicates = lines( mt_duplicates ).

    DATA: lv_sum_score TYPE p DECIMALS 2 VALUE 0.
    LOOP AT mt_scores INTO DATA(ls_sc).
      lv_sum_score = lv_sum_score + ls_sc-score.
    ENDLOOP.

    IF lines( mt_scores ) > 0.
      rs_summary-global_score = lv_sum_score / lines( mt_scores ).
    ELSE.
      rs_summary-global_score = 100.
    ENDIF.

    rs_summary-global_rating = mo_score_eng->derive_rating_band( rs_summary-global_score ).
  ENDMETHOD.

  METHOD get_score_results.
    rt_scores = mt_scores.
  ENDMETHOD.

  METHOD get_duplicates.
    rt_duplicates = mt_duplicates.
  ENDMETHOD.

ENDCLASS.
