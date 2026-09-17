INTERFACE ZIF_MDQ_DUPLICATE_ENGINE
  PUBLIC.

  METHODS detect_duplicate_customers
    IMPORTING
      io_repo              TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_duplicates) TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings.

  METHODS detect_duplicate_vendors
    IMPORTING
      io_repo              TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_duplicates) TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings.

  METHODS detect_duplicate_materials
    IMPORTING
      io_repo              TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_duplicates) TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings.

ENDINTERFACE.
