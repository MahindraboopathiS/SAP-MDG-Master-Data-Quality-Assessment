INTERFACE ZIF_MDQ_RULE_ENGINE
  PUBLIC.

  METHODS evaluate_materials
    IMPORTING
      io_repo            TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_findings) TYPE ZIF_MDQ_CONSTANTS=>tt_findings.

  METHODS evaluate_customers
    IMPORTING
      io_repo            TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_findings) TYPE ZIF_MDQ_CONSTANTS=>tt_findings.

  METHODS evaluate_vendors
    IMPORTING
      io_repo            TYPE REF TO ZIF_MDQ_REPOSITORY
    RETURNING
      VALUE(rt_findings) TYPE ZIF_MDQ_CONSTANTS=>tt_findings.

ENDINTERFACE.
