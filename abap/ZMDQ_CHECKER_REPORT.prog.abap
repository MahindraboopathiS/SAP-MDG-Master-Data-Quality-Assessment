*&---------------------------------------------------------------------*
*& Report ZMDQ_CHECKER_REPORT
*&---------------------------------------------------------------------*
*& SAP Master Data Quality Checker - Main Executable Report
*& Compatible with SAP R/3, ECC 6.0, SAP S/4HANA, and SAP BTP
*&---------------------------------------------------------------------*
REPORT ZMDQ_CHECKER_REPORT.

" Selection Screen Layout
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_mat  AS CHECKBOX DEFAULT 'X',
              p_cust AS CHECKBOX DEFAULT 'X',
              p_vend AS CHECKBOX DEFAULT 'X',
              p_bp   AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_mock RADIOBUTTON GROUP g1 DEFAULT 'X',
              p_prod RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_salv  RADIOBUTTON GROUP g2 DEFAULT 'X',
              p_excel RADIOBUTTON GROUP g2,
              p_csv   RADIOBUTTON GROUP g2.
SELECTION-SCREEN END OF BLOCK b3.

" Report Execution Events
START-OF-SELECTION.
  DATA: lo_repo     TYPE REF TO ZIF_MDQ_REPOSITORY,
        lo_service  TYPE REF TO ZCL_MDQ_REPORT_SERVICE,
        lo_salv_ui  TYPE REF TO ZCL_MDQ_REPORT_SALV,
        lo_exporter TYPE REF TO ZCL_MDQ_EXPORT_SERVICE.

  " 1. Instantiate Repository (Offline Mock vs Live Production DB)
  IF p_mock = abap_true.
    CREATE OBJECT lo_repo TYPE ZCL_MDQ_REPO_MOCK.
  ELSE.
    CREATE OBJECT lo_repo TYPE ZCL_MDQ_REPOSITORY.
  ENDIF.

  " 2. Instantiate Orchestration Service & Execute Audit
  CREATE OBJECT lo_service
    EXPORTING
      io_repo = lo_repo.

  DATA(ls_summary) = lo_service->execute_full_audit( ).
  DATA(lt_scores)  = lo_service->get_score_results( ).
  DATA(lt_dups)    = lo_service->get_duplicates( ).

  " 3. Process Output Mode
  IF p_salv = abap_true.
    CREATE OBJECT lo_salv_ui.
    lo_salv_ui->display_salv_grid( lt_scores ).
  ELSEIF p_excel = abap_true.
    CREATE OBJECT lo_exporter.
    DATA(lv_excel_xml) = lo_exporter->export_to_excel_xml(
      it_scores     = lt_scores
      it_duplicates = lt_dups
    ).
    WRITE: / 'Excel Spreadsheet XML generated successfully (', strlen( lv_excel_xml ), ' bytes)'.
  ELSEIF p_csv = abap_true.
    CREATE OBJECT lo_exporter.
    DATA(lv_csv_output) = lo_exporter->export_to_csv(
      it_scores     = lt_scores
      it_duplicates = lt_dups
    ).
    WRITE: / 'Strict Comma-Separated CSV generated successfully (', strlen( lv_csv_output ), ' bytes)'.
  ENDIF.
