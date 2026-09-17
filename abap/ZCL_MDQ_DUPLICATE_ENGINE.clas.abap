CLASS ZCL_MDQ_DUPLICATE_ENGINE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES ZIF_MDQ_DUPLICATE_ENGINE.

    METHODS calculate_levenshtein
      IMPORTING
        iv_str1        TYPE string
        iv_str2        TYPE string
      RETURNING
        VALUE(rv_dist) TYPE i.

    METHODS calculate_similarity
      IMPORTING
        iv_str1        TYPE string
        iv_str2        TYPE string
      RETURNING
        VALUE(rv_sim)  TYPE p DECIMALS 2.

ENDCLASS.

CLASS ZCL_MDQ_DUPLICATE_ENGINE IMPLEMENTATION.

  METHOD calculate_levenshtein.
    DATA: lv_len1 TYPE i,
          lv_len2 TYPE i,
          i       TYPE i,
          j       TYPE i,
          cost    TYPE i.

    DATA: lt_matrix TYPE STANDARD TABLE OF i WITH DEFAULT KEY,
          lv_idx    TYPE i,
          lv_v1     TYPE i,
          lv_v2     TYPE i,
          lv_v3     TYPE i.

    lv_len1 = strlen( iv_str1 ).
    lv_len2 = strlen( iv_str2 ).

    IF lv_len1 = 0.
      rv_dist = lv_len2.
      RETURN.
    ENDIF.

    IF lv_len2 = 0.
      rv_dist = lv_len1.
      RETURN.
    ENDIF.

    " Matrix dimensions: (lv_len1 + 1) * (lv_len2 + 1)
    " Initialize matrix
    DO ( lv_len1 + 1 ) * ( lv_len2 + 1 ) TIMES.
      APPEND 0 TO lt_matrix.
    ENDDO.

    " Fill first row and column
    DO lv_len1 + 1 TIMES.
      i = sy-index - 1.
      lv_idx = i * ( lv_len2 + 1 ) + 1.
      MODIFY lt_matrix FROM i INDEX lv_idx.
    ENDDO.

    DO lv_len2 + 1 TIMES.
      j = sy-index - 1.
      lv_idx = j + 1.
      MODIFY lt_matrix FROM j INDEX lv_idx.
    ENDDO.

    " Levenshtein distance matrix loop
    i = 1.
    WHILE i <= lv_len1.
      j = 1.
      WHILE j <= lv_len2.
        IF iv_str1+i(1) = iv_str2+j(1).
          cost = 0.
        ELSE.
          cost = 1.
        ENDIF.

        " Cell (i-1, j) + 1
        lv_idx = ( i - 1 ) * ( lv_len2 + 1 ) + j + 1.
        READ TABLE lt_matrix INDEX lv_idx INTO lv_v1.
        lv_v1 = lv_v1 + 1.

        " Cell (i, j-1) + 1
        lv_idx = i * ( lv_len2 + 1 ) + j.
        READ TABLE lt_matrix INDEX lv_idx INTO lv_v2.
        lv_v2 = lv_v2 + 1.

        " Cell (i-1, j-1) + cost
        lv_idx = ( i - 1 ) * ( lv_len2 + 1 ) + j.
        READ TABLE lt_matrix INDEX lv_idx INTO lv_v3.
        lv_v3 = lv_v3 + cost.

        " Minimum of v1, v2, v3
        DATA(lv_min) = lv_v1.
        IF lv_v2 < lv_min.
          lv_min = lv_v2.
        ENDIF.
        IF lv_v3 < lv_min.
          lv_min = lv_v3.
        ENDIF.

        " Store in cell (i, j)
        lv_idx = i * ( lv_len2 + 1 ) + j + 1.
        MODIFY lt_matrix FROM lv_min INDEX lv_idx.

        j = j + 1.
      ENDWHILE.
      i = i + 1.
    ENDWHILE.

    " Return cell (lv_len1, lv_len2)
    lv_idx = lv_len1 * ( lv_len2 + 1 ) + lv_len2 + 1.
    READ TABLE lt_matrix INDEX lv_idx INTO rv_dist.
  ENDMETHOD.

  METHOD calculate_similarity.
    DATA: lv_s1   TYPE string,
          lv_s2   TYPE string,
          lv_len1 TYPE i,
          lv_len2 TYPE i,
          lv_max  TYPE i,
          lv_dist TYPE i.

    lv_s1 = to_upper( iv_str1 ).
    lv_s2 = to_upper( iv_str2 ).

    condense lv_s1.
    condense lv_s2.

    lv_len1 = strlen( lv_s1 ).
    lv_len2 = strlen( lv_s2 ).

    IF lv_s1 = lv_s2.
      rv_sim = '100.00'.
      RETURN.
    ENDIF;

    IF lv_len1 = 0 OR lv_len2 = 0.
      rv_sim = '0.00'.
      RETURN.
    ENDIF.

    lv_max = lv_len1.
    IF lv_len2 > lv_max.
      lv_max = lv_len2.
    ENDIF.

    lv_dist = me->calculate_levenshtein( iv_str1 = lv_s1 iv_str2 = lv_s2 ).

    rv_sim = ( 1 - ( lv_dist / lv_max ) ) * 100.
  ENDMETHOD.

  METHOD ZIF_MDQ_DUPLICATE_ENGINE~detect_duplicate_customers.
    DATA(lr_cust_data) = io_repo->get_customer_master( ).
    FIELD-SYMBOLS <lt_customers> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_customers.
    ASSIGN lr_cust_data->* TO <lt_customers>.

    IF <lt_customers> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_customers> ASSIGNING FIELD-SYMBOL(<ls_c1>).
      LOOP AT <lt_customers> ASSIGNING FIELD-SYMBOL(<ls_c2>) WHERE kunnr > <ls_c1>-kunnr.
        " 1. Exact Tax ID Match Check
        IF <ls_c1>-stcd1 IS NOT INITIAL AND <ls_c1>-stcd1 = <ls_c2>-stcd1.
          APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
            object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
            primary_key = <ls_c1>-kunnr
            match_key   = <ls_c2>-kunnr
            similarity  = '100.00'
            match_type  = 'EXACT_TAX_ID'
            details     = |Duplicate Tax ID ({ <ls_c1>-stcd1 }) shared between customers { <ls_c1>-kunnr } and { <ls_c2>-kunnr }|
          ) TO rt_duplicates.
          CONTINUE.
        ENDIF.

        " 2. Fuzzy Name Match Check (Levenshtein >= 70%)
        IF <ls_c1>-name1 IS NOT INITIAL AND <ls_c2>-name1 IS NOT INITIAL.
          DATA(lv_name_sim) = me->calculate_similarity( iv_str1 = <ls_c1>-name1 iv_str2 = <ls_c2>-name1 ).
          IF lv_name_sim >= '70.00'.
            APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
              object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
              primary_key = <ls_c1>-kunnr
              match_key   = <ls_c2>-kunnr
              similarity  = lv_name_sim
              match_type  = 'FUZZY_NAME'
              details     = |Fuzzy Name match ({ lv_name_sim }%) between "{ <ls_c1>-name1 }" and "{ <ls_c2>-name1 }"|
            ) TO rt_duplicates.
          ENDIF.
        ENDIF.

        " 3. Fuzzy Address Match Check (Street + Postal Code >= 75%)
        IF <ls_c1>-stras IS NOT INITIAL AND <ls_c2>-stras IS NOT INITIAL.
          DATA(lv_addr1) = |{ <ls_c1>-stras } { <ls_c1>-pstlz }|.
          DATA(lv_addr2) = |{ <ls_c2>-stras } { <ls_c2>-pstlz }|.
          DATA(lv_addr_sim) = me->calculate_similarity( iv_str1 = lv_addr1 iv_str2 = lv_addr2 ).
          IF lv_addr_sim >= '75.00'.
            APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
              object_type = ZIF_MDQ_CONSTANTS=>gc_obj_customer
              primary_key = <ls_c1>-kunnr
              match_key   = <ls_c2>-kunnr
              similarity  = lv_addr_sim
              match_type  = 'FUZZY_ADDRESS'
              details     = |Fuzzy Address match ({ lv_addr_sim }%) between customers { <ls_c1>-kunnr } and { <ls_c2>-kunnr }|
            ) TO rt_duplicates.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD ZIF_MDQ_DUPLICATE_ENGINE~detect_duplicate_vendors.
    DATA(lr_vend_data) = io_repo->get_vendor_master( ).
    FIELD-SYMBOLS <lt_vendors> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_vendors.
    ASSIGN lr_vend_data->* TO <lt_vendors>.

    IF <lt_vendors> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_vendors> ASSIGNING FIELD-SYMBOL(<ls_v1>).
      LOOP AT <lt_vendors> ASSIGNING FIELD-SYMBOL(<ls_v2>) WHERE lifnr > <ls_v1>-lifnr.
        " 1. Exact Tax ID Match Check
        IF <ls_v1>-stcd1 IS NOT INITIAL AND <ls_v1>-stcd1 = <ls_v2>-stcd1.
          APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
            object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
            primary_key = <ls_v1>-lifnr
            match_key   = <ls_v2>-lifnr
            similarity  = '100.00'
            match_type  = 'EXACT_TAX_ID'
            details     = |Duplicate Tax ID ({ <ls_v1>-stcd1 }) shared between vendors { <ls_v1>-lifnr } and { <ls_v2>-lifnr }|
          ) TO rt_duplicates.
          CONTINUE.
        ENDIF.

        " 2. Fuzzy Name Match Check (Levenshtein >= 70%)
        IF <ls_v1>-name1 IS NOT INITIAL AND <ls_v2>-name1 IS NOT INITIAL.
          DATA(lv_vname_sim) = me->calculate_similarity( iv_str1 = <ls_v1>-name1 iv_str2 = <ls_v2>-name1 ).
          IF lv_vname_sim >= '70.00'.
            APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
              object_type = ZIF_MDQ_CONSTANTS=>gc_obj_vendor
              primary_key = <ls_v1>-lifnr
              match_key   = <ls_v2>-lifnr
              similarity  = lv_vname_sim
              match_type  = 'FUZZY_NAME'
              details     = |Fuzzy Name match ({ lv_vname_sim }%) between "{ <ls_v1>-name1 }" and "{ <ls_v2>-name1 }"|
            ) TO rt_duplicates.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD ZIF_MDQ_DUPLICATE_ENGINE~detect_duplicate_materials.
    DATA(lr_mat_data) = io_repo->get_material_master( ).
    FIELD-SYMBOLS <lt_materials> TYPE ZCL_MDQ_REPO_MOCK=>tt_mock_materials.
    ASSIGN lr_mat_data->* TO <lt_materials>.

    IF <lt_materials> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    LOOP AT <lt_materials> ASSIGNING FIELD-SYMBOL(<ls_m1>).
      IF <ls_m1>-maktx IS INITIAL.
        CONTINUE.
      ENDIF.

      LOOP AT <lt_materials> ASSIGNING FIELD-SYMBOL(<ls_m2>) WHERE matnr > <ls_m1>-matnr.
        " 1. Exact Description Match
        IF <ls_m1>-maktx = <ls_m2>-maktx.
          APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
            object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
            primary_key = <ls_m1>-matnr
            match_key   = <ls_m2>-matnr
            similarity  = '100.00'
            match_type  = 'EXACT_DESCRIPTION'
            details     = |Duplicate Material Description ("{ <ls_m1>-maktx }") shared between { <ls_m1>-matnr } and { <ls_m2>-matnr }|
          ) TO rt_duplicates.
          CONTINUE.
        ENDIF.

        " 2. Fuzzy Description Match within same Material Group (MATKL)
        IF <ls_m1>-matkl IS NOT INITIAL AND <ls_m1>-matkl = <ls_m2>-matkl.
          DATA(lv_mat_sim) = me->calculate_similarity( iv_str1 = <ls_m1>-maktx iv_str2 = <ls_m2>-maktx ).
          IF lv_mat_sim >= '70.00'.
            APPEND VALUE ZIF_MDQ_CONSTANTS=>ty_duplicate_finding(
              object_type = ZIF_MDQ_CONSTANTS=>gc_obj_material
              primary_key = <ls_m1>-matnr
              match_key   = <ls_m2>-matnr
              similarity  = lv_mat_sim
              match_type  = 'FUZZY_DESCRIPTION'
              details     = |Fuzzy Material Description match ({ lv_mat_sim }%) between "{ <ls_m1>-maktx }" and "{ <ls_m2>-maktx }"|
            ) TO rt_duplicates.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
