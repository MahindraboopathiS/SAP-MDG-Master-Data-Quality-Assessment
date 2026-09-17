CLASS ZCL_MDQ_REPO_MOCK DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES ZIF_MDQ_REPOSITORY.

    TYPES:
      BEGIN OF ty_mock_material,
        matnr TYPE string,
        maktx TYPE string,
        meins TYPE string,
        matkl TYPE string,
        werks TYPE string,
        vkorg TYPE string,
        mstae TYPE string,
        lvorm TYPE string,
        brgew TYPE p DECIMALS 3,
        ntgew TYPE p DECIMALS 3,
        gewei TYPE string,
        klass TYPE string,
      END OF ty_mock_material,
      tt_mock_materials TYPE STANDARD TABLE OF ty_mock_material WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_mock_customer,
        kunnr TYPE string,
        name1 TYPE string,
        stras TYPE string,
        ort01 TYPE string,
        pstlz TYPE string,
        land1 TYPE string,
        stcd1 TYPE string,
        zterm TYPE string,
        vkorg TYPE string,
        sperr TYPE string,
        email TYPE string,
        kdgrp TYPE string,
        klass TYPE string,
      END OF ty_mock_customer,
      tt_mock_customers TYPE STANDARD TABLE OF ty_mock_customer WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_mock_vendor,
        lifnr TYPE string,
        name1 TYPE string,
        stras TYPE string,
        ort01 TYPE string,
        pstlz TYPE string,
        land1 TYPE string,
        stcd1 TYPE string,
        zterm TYPE string,
        ekorg TYPE string,
        sperr TYPE string,
        email TYPE string,
        klass TYPE string,
      END OF ty_mock_vendor,
      tt_mock_vendors TYPE STANDARD TABLE OF ty_mock_vendor WITH DEFAULT KEY.

    METHODS constructor.

  PRIVATE SECTION.
    DATA mt_rules     TYPE ZIF_MDQ_CONSTANTS=>tt_rules.
    DATA mt_materials TYPE tt_mock_materials.
    DATA mt_customers TYPE tt_mock_customers.
    DATA mt_vendors   TYPE tt_mock_vendors.

    METHODS init_mock_data.
ENDCLASS.

CLASS ZCL_MDQ_REPO_MOCK IMPLEMENTATION.

  METHOD constructor.
    me->init_mock_data( ).
  ENDMETHOD.

  METHOD init_mock_data.
    " Initialize mock quality rules (28 rules: FR-001 to FR-028)
    mt_rules = VALUE #(
      ( rule_id = 'FR-001' object_type = 'MAT' field_name = 'MAKTX' description = 'Detect materials missing description' severity = 'CRITICAL' weight = 25 is_active = abap_true )
      ( rule_id = 'FR-002' object_type = 'MAT' field_name = 'MEINS' description = 'Detect materials missing base unit of measure' severity = 'CRITICAL' weight = 25 is_active = abap_true )
      ( rule_id = 'FR-003' object_type = 'MAT' field_name = 'MATKL' description = 'Detect materials missing material group' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-004' object_type = 'MAT' field_name = 'WERKS' description = 'Detect materials without plant assignment' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-005' object_type = 'MAT' field_name = 'VKORG' description = 'Detect materials missing sales data' severity = 'MEDIUM' weight = 10 is_active = abap_true )
      ( rule_id = 'FR-006' object_type = 'MAT' field_name = 'MSTAE' description = 'Detect blocked materials' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-007' object_type = 'MAT' field_name = 'LVORM' description = 'Detect obsolete materials' severity = 'MEDIUM' weight = 10 is_active = abap_true )
      ( rule_id = 'FR-008' object_type = 'MAT' field_name = 'MAKTX' description = 'Detect duplicate materials by description' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-009' object_type = 'MAT' field_name = 'KLASS' description = 'Detect unclassified materials' severity = 'LOW' weight = 5 is_active = abap_true )
      ( rule_id = 'FR-010' object_type = 'MAT' field_name = 'GEWEI' description = 'Detect materials missing weight/dimensions' severity = 'LOW' weight = 5 is_active = abap_true )

      ( rule_id = 'FR-011' object_type = 'CUST' field_name = 'NAME1' description = 'Detect customers missing name' severity = 'CRITICAL' weight = 25 is_active = abap_true )
      ( rule_id = 'FR-012' object_type = 'CUST' field_name = 'STRAS' description = 'Detect customers missing street address' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-013' object_type = 'CUST' field_name = 'LAND1' description = 'Detect customers missing country' severity = 'CRITICAL' weight = 25 is_active = abap_true )
      ( rule_id = 'FR-014' object_type = 'CUST' field_name = 'STCD1' description = 'Detect customers missing Tax ID' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-015' object_type = 'CUST' field_name = 'ZTERM' description = 'Detect customers missing payment terms' severity = 'MEDIUM' weight = 10 is_active = abap_true )
      ( rule_id = 'FR-016' object_type = 'CUST' field_name = 'VKORG' description = 'Detect customers missing sales org' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-017' object_type = 'CUST' field_name = 'SPERR' description = 'Detect blocked customers' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-018' object_type = 'CUST' field_name = 'STCD1' description = 'Detect duplicate customers by Tax ID' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-019' object_type = 'CUST' field_name = 'SMTP_ADDR' description = 'Detect customers missing email' severity = 'LOW' weight = 5 is_active = abap_true )
      ( rule_id = 'FR-020' object_type = 'CUST' field_name = 'KDGRP' description = 'Detect customers missing commercial class' severity = 'LOW' weight = 5 is_active = abap_true )

      ( rule_id = 'FR-021' object_type = 'VEND' field_name = 'STCD1' description = 'Detect vendors missing Tax ID' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-022' object_type = 'VEND' field_name = 'ZTERM' description = 'Detect vendors missing payment terms' severity = 'MEDIUM' weight = 10 is_active = abap_true )
      ( rule_id = 'FR-023' object_type = 'VEND' field_name = 'STRAS' description = 'Detect vendors missing street address' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-024' object_type = 'VEND' field_name = 'STCD1' description = 'Detect duplicate vendors by Tax ID' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-025' object_type = 'VEND' field_name = 'SPERR' description = 'Detect blocked vendors' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-026' object_type = 'VEND' field_name = 'EKORG' description = 'Detect vendors missing purchasing org' severity = 'HIGH' weight = 15 is_active = abap_true )
      ( rule_id = 'FR-027' object_type = 'VEND' field_name = 'KLASS' description = 'Detect vendors missing classification' severity = 'LOW' weight = 5 is_active = abap_true )
      ( rule_id = 'FR-028' object_type = 'VEND' field_name = 'SMTP_ADDR' description = 'Detect vendors missing email' severity = 'LOW' weight = 5 is_active = abap_true )
    ).

    " Initialize mock materials
    mt_materials = VALUE #(
      ( matnr = '000000000000001001' maktx = 'Industrial Water Pump 500W' meins = 'EA' matkl = '00101' werks = '1000' vkorg = '1000' mstae = ''   lvorm = ''  brgew = '12.500' ntgew = '10.000' gewei = 'KG' klass = 'PUMP_01' )
      ( matnr = '000000000000001002' maktx = ''                          meins = ''   matkl = '00202' werks = ''     vkorg = ''     mstae = ''   lvorm = ''  brgew = '0.000'  ntgew = '0.000'  gewei = ''   klass = '' )
      ( matnr = '000000000000001003' maktx = 'Steel Sheet 5mm Grade A'   meins = 'KG' matkl = ''      werks = '1000' vkorg = '1000' mstae = '01' lvorm = 'X' brgew = '50.000' ntgew = '48.000' gewei = 'KG' klass = '' )
      ( matnr = '000000000000001004' maktx = 'Industrial Water Pump 500W' meins = 'EA' matkl = '00101' werks = '1000' vkorg = '1000' mstae = ''   lvorm = ''  brgew = '15.000' ntgew = '14.000' gewei = 'KG' klass = 'PUMP_01' )
    ).

    " Initialize mock customers
    mt_customers = VALUE #(
      ( kunnr = '0000100001' name1 = 'ACME Corporation SA' stras = 'Main Street 100' ort01 = 'Buenos Aires' pstlz = 'C1001AAA' land1 = 'AR' stcd1 = '30112233445' zterm = 'NT30' vkorg = '1000' sperr = ''  email = 'info@acme.com' kdgrp = '01' klass = 'CORP' )
      ( kunnr = '0000100002' name1 = ''                    stras = ''               ort01 = ''             pstlz = ''         land1 = 'US' stcd1 = ''            zterm = ''     vkorg = ''     sperr = 'X' email = ''              kdgrp = ''   klass = '' )
      ( kunnr = '0000100003' name1 = 'Acme Corp S.A.'      stras = 'Main St. 102'   ort01 = 'Buenos Aires' pstlz = 'C1001AAA' land1 = 'AR' stcd1 = '30112233445' zterm = 'NT30' vkorg = '1000' sperr = ''  email = ''              kdgrp = '01' klass = '' )
    ).

    " Initialize mock vendors
    mt_vendors = VALUE #(
      ( lifnr = '0000200001' name1 = 'Global Logistics Services SRL' stras = 'Av. Corrientes 500' ort01 = 'Buenos Aires' pstlz = 'C1043AAB' land1 = 'AR' stcd1 = '30998877661' zterm = 'NT60' ekorg = '1000' sperr = ''  email = 'logistics@global.com' klass = 'LOGISTICS' )
      ( lifnr = '0000200002' name1 = 'Hardware Supplies Ltd'          stras = ''                   ort01 = ''             pstlz = ''         land1 = 'DE' stcd1 = ''            zterm = ''     ekorg = ''     sperr = 'X' email = ''                     klass = '' )
    ).
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_active_rules.
    IF iv_object_type IS INITIAL.
      rt_rules = mt_rules.
    ELSE.
      LOOP AT mt_rules INTO DATA(ls_rule) WHERE object_type = iv_object_type AND is_active = abap_true.
        APPEND ls_rule TO rt_rules.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_material_master.
    GET REFERENCE OF mt_materials INTO rt_materials.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_customer_master.
    GET REFERENCE OF mt_customers INTO rt_customers.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_vendor_master.
    GET REFERENCE OF mt_vendors INTO rt_vendors.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_bp_master.
    GET REFERENCE OF mt_customers INTO rt_bps.
  ENDMETHOD.

ENDCLASS.
