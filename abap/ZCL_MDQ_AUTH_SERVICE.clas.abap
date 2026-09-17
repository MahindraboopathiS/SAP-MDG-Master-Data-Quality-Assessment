CLASS ZCL_MDQ_AUTH_SERVICE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS check_material_authorization
      IMPORTING
        iv_actvt         TYPE string DEFAULT '03'
      RETURNING
        VALUE(rv_auth)   TYPE abap_bool.

    METHODS check_customer_authorization
      IMPORTING
        iv_actvt         TYPE string DEFAULT '03'
      RETURNING
        VALUE(rv_auth)   TYPE abap_bool.

    METHODS check_vendor_authorization
      IMPORTING
        iv_actvt         TYPE string DEFAULT '03'
      RETURNING
        VALUE(rv_auth)   TYPE abap_bool.

ENDCLASS.

CLASS ZCL_MDQ_AUTH_SERVICE IMPLEMENTATION.

  METHOD check_material_authorization.
    " Simulates AUTHORITY-CHECK OBJECT 'M_MATE_STA' ID 'ACTVT' FIELD iv_actvt
    " In offline simulation, authorization is granted
    rv_auth = abap_true.
  ENDMETHOD.

  METHOD check_customer_authorization.
    " Simulates AUTHORITY-CHECK OBJECT 'V_VBAK_VKO' ID 'ACTVT' FIELD iv_actvt
    rv_auth = abap_true.
  ENDMETHOD.

  METHOD check_vendor_authorization.
    " Simulates AUTHORITY-CHECK OBJECT 'M_BEST_EKO' ID 'ACTVT' FIELD iv_actvt
    rv_auth = abap_true.
  ENDMETHOD.

ENDCLASS.
