CLASS ZCL_MDQ_EXPORT_SERVICE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS export_to_csv
      IMPORTING
        it_scores       TYPE ZIF_MDQ_CONSTANTS=>tt_score_results
        it_duplicates   TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings
      RETURNING
        VALUE(rv_csv)   TYPE string.

    METHODS export_to_excel_xml
      IMPORTING
        it_scores       TYPE ZIF_MDQ_CONSTANTS=>tt_score_results
        it_duplicates   TYPE ZIF_MDQ_CONSTANTS=>tt_duplicate_findings
      RETURNING
        VALUE(rv_xml)   TYPE string.

  PRIVATE SECTION.
    METHODS escape_csv_field
      IMPORTING
        iv_field        TYPE string
      RETURNING
        VALUE(rv_field) TYPE string.
ENDCLASS.

CLASS ZCL_MDQ_EXPORT_SERVICE IMPLEMENTATION.

  METHOD escape_csv_field.
    rv_field = iv_field.
    " Standard CSV: If field contains comma or quotes, enclose in quotes and double internal quotes
    IF rv_field CS ',' OR rv_field CS '"' OR rv_field CS cl_abap_char_utilities=>newline.
      REPLACE ALL OCCURRENCES OF '"' IN rv_field WITH '""'.
      rv_field = |"{ rv_field }"|.
    ENDIF.
  ENDMETHOD.

  METHOD export_to_csv.
    DATA: lv_line TYPE string.

    " CSV Header - Quality Scores (Strictly Comma Separated)
    rv_csv = |OBJECT_TYPE,OBJECT_KEY,SCORE,RATING_BAND,FINDINGS_COUNT,RULE_ID,SEVERITY,FIELD_NAME,MESSAGE\n|.

    LOOP AT it_scores INTO DATA(ls_score).
      IF lines( ls_score-findings ) = 0.
        lv_line = |{ me->escape_csv_field( ls_score-object_type ) },{ me->escape_csv_field( ls_score-object_key ) },{ ls_score-score },{ me->escape_csv_field( ls_score-rating_band ) },0,,,,\n|.
        CONCATENATE rv_csv lv_line INTO rv_csv.
      ELSE.
        LOOP AT ls_score-findings INTO DATA(ls_finding).
          lv_line = |{ me->escape_csv_field( ls_score-object_type ) },{ me->escape_csv_field( ls_score-object_key ) },{ ls_score-score },{ me->escape_csv_field( ls_score-rating_band ) },{ lines( ls_score-findings ) },{ me->escape_csv_field( ls_finding-rule_id ) },{ me->escape_csv_field( ls_finding-severity ) },{ me->escape_csv_field( ls_finding-field_name ) },{ me->escape_csv_field( ls_finding-message ) }\n|.
          CONCATENATE rv_csv lv_line INTO rv_csv.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    " Append Duplicates Section if available
    IF lines( it_duplicates ) > 0.
      CONCATENATE rv_csv |\nDUPLICATE_OBJECT_TYPE,PRIMARY_KEY,MATCH_KEY,SIMILARITY_PCT,MATCH_TYPE,DETAILS\n| INTO rv_csv.
      LOOP AT it_duplicates INTO DATA(ls_dup).
        lv_line = |{ me->escape_csv_field( ls_dup-object_type ) },{ me->escape_csv_field( ls_dup-primary_key ) },{ me->escape_csv_field( ls_dup-match_key ) },{ ls_dup-similarity },{ me->escape_csv_field( ls_dup-match_type ) },{ me->escape_csv_field( ls_dup-details ) }\n|.
        CONCATENATE rv_csv lv_line INTO rv_csv.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD export_to_excel_xml.
    " Generate Excel Spreadsheet XML 2003 format (.xml / .xlsx compatible)
    rv_xml = |<?xml version="1.0"?>\n|.
    CONCATENATE rv_xml |<?mso-application progid="Excel.Sheet"?>\n| INTO rv_xml.
    CONCATENATE rv_xml |<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"\n| INTO rv_xml.
    CONCATENATE rv_xml | xmlns:o="urn:schemas-microsoft-com:office:office"\n| INTO rv_xml.
    CONCATENATE rv_xml | xmlns:x="urn:schemas-microsoft-com:office:excel"\n| INTO rv_xml.
    CONCATENATE rv_xml | xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">\n| INTO rv_xml.

    " Worksheet 1: Quality Findings & Scores
    CONCATENATE rv_xml | <Worksheet ss:Name="Master Data Quality Scores">\n| INTO rv_xml.
    CONCATENATE rv_xml |  <Table>\n| INTO rv_xml.
    CONCATENATE rv_xml |   <Row>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Object Type</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Object Key</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Quality Score (%)</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Rating Band</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Rule ID</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Severity</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Field Name</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Diagnostic Message</Data></Cell>\n| INTO rv_xml.
    CONCATENATE rv_xml |   </Row>\n| INTO rv_xml.

    LOOP AT it_scores INTO DATA(ls_score).
      IF lines( ls_score-findings ) = 0.
        CONCATENATE rv_xml |   <Row>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-object_type }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-object_key }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="Number">{ ls_score-score }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-rating_band }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">NONE</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">OK</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">-</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">No findings detected</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |   </Row>\n| INTO rv_xml.
      ELSE.
        LOOP AT ls_score-findings INTO DATA(ls_finding).
          CONCATENATE rv_xml |   <Row>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-object_type }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-object_key }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="Number">{ ls_score-score }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_score-rating_band }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_finding-rule_id }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_finding-severity }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_finding-field_name }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_finding-message }</Data></Cell>\n| INTO rv_xml.
          CONCATENATE rv_xml |   </Row>\n| INTO rv_xml.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    CONCATENATE rv_xml |  </Table>\n| INTO rv_xml.
    CONCATENATE rv_xml | </Worksheet>\n| INTO rv_xml.

    " Worksheet 2: Duplicate Findings
    IF lines( it_duplicates ) > 0.
      CONCATENATE rv_xml | <Worksheet ss:Name="Duplicate Detection Findings">\n| INTO rv_xml.
      CONCATENATE rv_xml |  <Table>\n| INTO rv_xml.
      CONCATENATE rv_xml |   <Row>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Object Type</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Primary Record Key</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Matching Record Key</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Similarity (%)</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Match Type</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |    <Cell><Data ss:Type="String">Details</Data></Cell>\n| INTO rv_xml.
      CONCATENATE rv_xml |   </Row>\n| INTO rv_xml.

      LOOP AT it_duplicates INTO DATA(ls_dup).
        CONCATENATE rv_xml |   <Row>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_dup-object_type }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_dup-primary_key }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_dup-match_key }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="Number">{ ls_dup-similarity }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_dup-match_type }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |    <Cell><Data ss:Type="String">{ ls_dup-details }</Data></Cell>\n| INTO rv_xml.
        CONCATENATE rv_xml |   </Row>\n| INTO rv_xml.
      ENDLOOP.

      CONCATENATE rv_xml |  </Table>\n| INTO rv_xml.
      CONCATENATE rv_xml | </Worksheet>\n| INTO rv_xml.
    ENDIF.

    CONCATENATE rv_xml |</Workbook>\n| INTO rv_xml.
  ENDMETHOD.

ENDCLASS.
