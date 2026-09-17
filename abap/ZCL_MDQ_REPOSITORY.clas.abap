CLASS ZCL_MDQ_REPOSITORY DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES ZIF_MDQ_REPOSITORY.

    TYPES:
      BEGIN OF ty_db_material,
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
      END OF ty_db_material,
      tt_db_materials TYPE STANDARD TABLE OF ty_db_material WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_db_customer,
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
      END OF ty_db_customer,
      tt_db_customers TYPE STANDARD TABLE OF ty_db_customer WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_db_vendor,
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
      END OF ty_db_vendor,
      tt_db_vendors TYPE STANDARD TABLE OF ty_db_vendor WITH DEFAULT KEY.

  PRIVATE SECTION.
    DATA mt_materials TYPE tt_db_materials.
    DATA mt_customers TYPE tt_db_customers.
    DATA mt_vendors   TYPE tt_db_vendors.
    DATA mt_rules     TYPE ZIF_MDQ_CONSTANTS=>tt_rules.
ENDCLASS.

CLASS ZCL_MDQ_REPOSITORY IMPLEMENTATION.

  METHOD ZIF_MDQ_REPOSITORY~get_active_rules.
    " Production DB query against custom rule table ZMDQ_RULE
    " SELECT rule_id, object_type, field_name, description, severity, weight, is_active
    "   FROM zmdq_rule INTO TABLE @rt_rules WHERE is_active = @abap_true.
    IF iv_object_type IS INITIAL.
      rt_rules = mt_rules.
    ELSE.
      LOOP AT mt_rules INTO DATA(ls_rule) WHERE object_type = iv_object_type AND is_active = abap_true.
        APPEND ls_rule TO rt_rules.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_material_master.
    " Production Open SQL Query with FOR ALL ENTRIES IN / JOIN (Oracle DB / R/3 & S/4HANA Compatible)
    " Avoid SELECT * and SELECT inside LOOP blocks.
    " SELECT mara~matnr, makt~maktx, mara~meins, mara~matkl, marc~werks, mvke~vkorg
    "   FROM mara
    "   LEFT OUTER JOIN makt ON makt~matnr = mara~matnr AND makt~spras = @sy-langu
    "   LEFT OUTER JOIN marc ON marc~matnr = mara~matnr
    "   LEFT OUTER JOIN mvke ON mvke~matnr = mara~matnr
    "   INTO TABLE @mt_materials.

    GET REFERENCE OF mt_materials INTO rt_materials.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_customer_master.
    " Production Open SQL Query with FOR ALL ENTRIES IN (Oracle DB / R/3 Compatible)
    " SELECT kna1~kunnr, kna1~name1, kna1~stras, kna1~ort01, kna1~pstlz, kna1~land1, kna1~stcd1, knb1~zterm, knvv~vkorg
    "   FROM kna1
    "   LEFT OUTER JOIN knb1 ON knb1~kunnr = kna1~kunnr
    "   LEFT OUTER JOIN knvv ON knvv~kunnr = kna1~kunnr
    "   INTO TABLE @mt_customers.

    GET REFERENCE OF mt_customers INTO rt_customers.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_vendor_master.
    " Production Open SQL Query with FOR ALL ENTRIES IN (Oracle DB / R/3 Compatible)
    " SELECT lfa1~lifnr, lfa1~name1, lfa1~stras, lfa1~ort01, lfa1~pstlz, lfa1~land1, lfa1~stcd1, lfb1~zterm, lfm1~ekorg
    "   FROM lfa1
    "   LEFT OUTER JOIN lfb1 ON lfb1~lifnr = lfa1~lifnr
    "   LEFT OUTER JOIN lfm1 ON lfm1~lifnr = lfa1~lifnr
    "   INTO TABLE @mt_vendors.

    GET REFERENCE OF mt_vendors INTO rt_vendors.
  ENDMETHOD.

  METHOD ZIF_MDQ_REPOSITORY~get_bp_master.
    " Production Query for S/4HANA Business Partner tables BUT000 / BUT020
    GET REFERENCE OF mt_customers INTO rt_bps.
  ENDMETHOD.

ENDCLASS.
