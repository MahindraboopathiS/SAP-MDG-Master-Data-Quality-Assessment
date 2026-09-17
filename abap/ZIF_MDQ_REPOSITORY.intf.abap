INTERFACE ZIF_MDQ_REPOSITORY
  PUBLIC.

  METHODS get_active_rules
    IMPORTING
      iv_object_type  TYPE string OPTIONAL
    RETURNING
      VALUE(rt_rules) TYPE ZIF_MDQ_CONSTANTS=>tt_rules.

  METHODS get_material_master
    RETURNING
      VALUE(rt_materials) TYPE ref to data.

  METHODS get_customer_master
    RETURNING
      VALUE(rt_customers) TYPE ref to data.

  METHODS get_vendor_master
    RETURNING
      VALUE(rt_vendors) TYPE ref to data.

  METHODS get_bp_master
    RETURNING
      VALUE(rt_bps) TYPE ref to data.

ENDINTERFACE.
