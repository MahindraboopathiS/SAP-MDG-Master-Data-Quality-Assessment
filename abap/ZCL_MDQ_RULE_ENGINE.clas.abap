CLASS ZCL_MDQ_RULE_ENGINE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES ZIF_MDQ_RULE_ENGINE.

ENDCLASS.

CLASS ZCL_MDQ_RULE_ENGINE IMPLEMENTATION.

  METHOD ZIF_MDQ_RULE_ENGINE~evaluate_materials.
    DATA(lr_mat_data) = io_repo->get_material_master( ).
    FIELD-SYMBOLS <lt_materials> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_materials.
    ASSIGN lr_mat_data->* TO <lt_materials>.

    IF <lt_materials> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_materials> ASSIGNING FIELD-SYMBOL(<ls_mat>).
      " FR-001: Missing Description
      IF <ls_mat>-maktx IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-001'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_critical
          field_name  = 'MAKTX'
          message     = 'Material missing description (MAKT-MAKTX)'
        ) TO rt_findings.
      ENDIF.

      " FR-002: Missing Base Unit of Measure
      IF <ls_mat>-meins IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-002'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_critical
          field_name  = 'MEINS'
          message     = 'Material missing Base Unit of Measure (MARA-MEINS)'
        ) TO rt_findings.
      ENDIF.

      " FR-003: Missing Material Group
      IF <ls_mat>-matkl IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-003'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'MATKL'
          message     = 'Material missing Material Group (MARA-MATKL)'
        ) TO rt_findings.
      ENDIF.

      " FR-004: Missing Plant Assignment
      IF <ls_mat>-werks IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-004'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'WERKS'
          message     = 'Material not assigned to any Plant (MARC-WERKS)'
        ) TO rt_findings.
      ENDIF.

      " FR-005: Missing Sales Data
      IF <ls_mat>-vkorg IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-005'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_medium
          field_name  = 'VKORG'
          message     = 'Material missing Sales Organization data (MVKE-VKORG)'
        ) TO rt_findings.
      ENDIF.

      " FR-006: Blocked Material
      IF <ls_mat>-mstae IS NOT INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-006'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'MSTAE'
          message     = |Material blocked with maintenance status { <ls_mat>-mstae }|
        ) TO rt_findings.
      ENDIF.

      " FR-007: Obsolete Material
      IF <ls_mat>-lvorm IS NOT INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-007'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_medium
          field_name  = 'LVORM'
          message     = 'Material marked for deletion / obsolete (MARA-LVORM)'
        ) TO rt_findings.
      ENDIF.

      " FR-009: Unclassified Material
      IF <ls_mat>-klass IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-009'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'KLASS'
          message     = 'Material missing classification assignment'
        ) TO rt_findings.
      ENDIF.

      " FR-010: Missing Weight / Dimensions
      IF <ls_mat>-brgew = 0 OR <ls_mat>-gewei IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
          object_key  = <ls_mat>-matnr
          rule_id     = 'FR-010'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'GEWEI'
          message     = 'Material missing weight or weight unit (MARA-BRGEW/GEWEI)'
        ) TO rt_findings.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD ZIF_MDQ_RULE_ENGINE~evaluate_customers.
    DATA(lr_cust_data) = io_repo->get_customer_master( ).
    FIELD-SYMBOLS <lt_customers> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_customers.
    ASSIGN lr_cust_data->* TO <lt_customers>.

    IF <lt_customers> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_customers> ASSIGNING FIELD-SYMBOL(<ls_cust>).
      " FR-011: Missing Name
      IF <ls_cust>-name1 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-011'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_critical
          field_name  = 'NAME1'
          message     = 'Customer missing Name (KNA1-NAME1)'
        ) TO rt_findings.
      ENDIF.

      " FR-012: Missing Address
      IF <ls_cust>-stras IS INITIAL OR <ls_cust>-ort01 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-012'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'STRAS'
          message     = 'Customer missing Street or City address (KNA1-STRAS/ORT01)'
        ) TO rt_findings.
      ENDIF.

      " FR-013: Missing Country
      IF <ls_cust>-land1 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-013'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_critical
          field_name  = 'LAND1'
          message     = 'Customer missing Country code (KNA1-LAND1)'
        ) TO rt_findings.
      ENDIF.

      " FR-014: Missing Tax ID
      IF <ls_cust>-stcd1 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-014'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'STCD1'
          message     = 'Customer missing Tax ID / VAT Number (KNA1-STCD1)'
        ) TO rt_findings.
      ENDIF.

      " FR-015: Missing Payment Terms
      IF <ls_cust>-zterm IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-015'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_medium
          field_name  = 'ZTERM'
          message     = 'Customer missing Payment Terms (KNB1-ZTERM)'
        ) TO rt_findings.
      ENDIF.

      " FR-016: Missing Sales Org
      IF <ls_cust>-vkorg IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-016'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'VKORG'
          message     = 'Customer missing Sales Organization assignment (KNVV-VKORG)'
        ) TO rt_findings.
      ENDIF.

      " FR-017: Blocked Customer
      IF <ls_cust>-sperr IS NOT INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-017'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'SPERR'
          message     = 'Customer is posted with Central Posting Block (KNA1-SPERR)'
        ) TO rt_findings.
      ENDIF.

      " FR-019: Missing Email
      IF <ls_cust>-email IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-019'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'SMTP_ADDR'
          message     = 'Customer missing email address'
        ) TO rt_findings.
      ENDIF.

      " FR-020: Missing Commercial Classification
      IF <ls_cust>-kdgrp IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
          object_key  = <ls_cust>-kunnr
          rule_id     = 'FR-020'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'KDGRP'
          message     = 'Customer missing Customer Group classification (KNVV-KDGRP)'
        ) TO rt_findings.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD ZIF_MDQ_RULE_ENGINE~evaluate_vendors.
    DATA(lr_vend_data) = io_repo->get_vendor_master( ).
    FIELD-SYMBOLS <lt_vendors> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_vendors.
    ASSIGN lr_vend_data->* TO <lt_vendors>.

    IF <lt_vendors> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_vendors> ASSIGNING FIELD-SYMBOL(<ls_vend>).
      " FR-021: Missing Tax ID
      IF <ls_vend>-stcd1 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-021'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'STCD1'
          message     = 'Vendor missing Tax ID (LFA1-STCD1)'
        ) TO rt_findings.
      ENDIF.

      " FR-022: Missing Payment Terms
      IF <ls_vend>-zterm IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-022'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_medium
          field_name  = 'ZTERM'
          message     = 'Vendor missing Payment Terms (LFB1-ZTERM)'
        ) TO rt_findings.
      ENDIF.

      " FR-023: Missing Address
      IF <ls_vend>-stras IS INITIAL OR <ls_vend>-ort01 IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-023'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'STRAS'
          message     = 'Vendor missing Street or City address (LFA1-STRAS/ORT01)'
        ) TO rt_findings.
      ENDIF.

      " FR-025: Blocked Vendor
      IF <ls_vend>-sperr IS NOT INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-025'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'SPERR'
          message     = 'Vendor is posted with Central Posting Block (LFA1-SPERR)'
        ) TO rt_findings.
      ENDIF.

      " FR-026: Missing Purchasing Org
      IF <ls_vend>-ekorg IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-026'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_high
          field_name  = 'EKORG'
          message     = 'Vendor missing Purchasing Organization assignment (LFM1-EKORG)'
        ) TO rt_findings.
      ENDIF.

      " FR-027: Missing Classification
      IF <ls_vend>-klass IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-027'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'KLASS'
          message     = 'Vendor missing classification assignment'
        ) TO rt_findings.
      ENDIF.

      " FR-028: Missing Email
      IF <ls_vend>-email IS INITIAL.
        APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_finding(
          object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
          object_key  = <ls_vend>-lifnr
          rule_id     = 'FR-028'
          severity    = ZIF_MDQ_CONSTANTS=>gc_sev_low
          field_name  = 'SMTP_ADDR'
          message     = 'Vendor missing email address'
        ) TO rt_findings.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
