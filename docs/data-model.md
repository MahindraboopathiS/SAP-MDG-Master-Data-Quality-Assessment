# Data Model & Schema Specification

> Relational & Entity-Relationship specification for SAP Standard Master Data tables, Customizing tables, and Runtime Audit Log tables.

---

## 1. SAP Standard Master Data Entities

### 1.1 Material Master (MM)
- `MARA`: General Material Data (`MATNR`, `MTART`, `MATKL`, `MEINS`, `BRGEW`, `NTGEW`, `MSTAE`).
- `MAKT`: Material Descriptions (`MATNR`, `SPRAS`, `MAKTX`).
- `MARC`: Plant Data for Material (`MATNR`, `WERKS`, `LVORM`, `DISPO`).
- `MVKE`: Sales Data for Material (`MATNR`, `VKORG`, `VTWEG`, `DVKLS`).

### 1.2 Customer Master (SD / FI)
- `KNA1`: General Customer Master (`KUNNR`, `NAME1`, `STRAS`, `ORT01`, `PSTLZ`, `LAND1`, `STCD1`, `STCEG`, `SPERR`).
- `KNB1`: Customer Company Code Data (`KUNNR`, `BUKRS`, `ZTERM`, `AKONT`).
- `KNVV`: Customer Sales Data (`KUNNR`, `VKORG`, `VTWEG`, `SPART`, `KDGRP`).

### 1.3 Vendor Master (MM / FI)
- `LFA1`: General Vendor Master (`LIFNR`, `NAME1`, `STRAS`, `ORT01`, `PSTLZ`, `LAND1`, `STCD1`, `SPERR`).
- `LFB1`: Vendor Company Code Data (`LIFNR`, `BUKRS`, `ZTERM`, `AKONT`).
- `LFM1`: Vendor Purchasing Data (`LIFNR`, `EKORG`, `WAERS`).

### 1.4 Business Partner (S/4HANA BP / MDG)
- `BUT000`: Business Partner Header (`PARTNER`, `TYPE`, `NAME_ORG1`, `NAME_FIRST`, `NAME_LAST`, `BU_SORT1`).
- `BUT020`: BP Addresses (`PARTNER`, `ADDRNUMBER`).
- `BUT0ID`: BP Identification Numbers (`PARTNER`, `TYPE`, `IDNUMBER`).

---

## 2. Framework Customizing Tables

### 2.1 Quality Rules Table (`ZMDQ_RULE`)
| Field Name | Key | Data Element | Description |
| :--- | :---: | :--- | :--- |
| `MANDT` | KEY | `MANDT` | Client |
| `RULE_ID` | KEY | `CHAR30` | Unique Quality Rule ID (e.g., `FR-001`, `FR-014`) |
| `OBJECT_TYPE` | | `CHAR10` | Business Object Type (`MAT`, `CUST`, `VEND`, `BP`) |
| `FIELD_NAME` | | `FDNAME` | Target SAP Field Name |
| `DESCRIPTION` | | `CHAR100` | Rule Description & Remediation Advice |
| `SEVERITY` | | `CHAR10` | Rule Severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`) |
| `WEIGHT` | | `INT2` | Deductive Deduction Weight |
| `IS_ACTIVE` | | `CHAR1` | Active Flag (`X` / ` `) |

### 2.2 Quality Severities Table (`ZMDQ_SEVERITY`)
| Field Name | Key | Description | Deduction Points |
| :--- | :---: | :--- | :---: |
| `SEVERITY_CODE` | KEY | Severity Code (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`) | - |
| `DEDUCTION_POINTS` | | Weight deducted from score | `25`, `15`, `10`, `5` |

---

## 3. Runtime Audit & Results Schema

### 3.1 Validation Result Entity (`ValidationResult`)
- `EXECUTION_ID`: GUID identifying the run.
- `OBJECT_TYPE`: Business Object (`MAT`, `CUST`, `VEND`, `BP`).
- `OBJECT_KEY`: Master Data Primary Key (`MATNR`, `KUNNR`, `LIFNR`, `PARTNER`).
- `RULE_ID`: Violated Rule ID.
- `SEVERITY`: Severity level of finding.
- `FIELD_NAME`: Defective SAP field name.
- `MESSAGE`: Detailed explainable diagnostic message.

### 3.2 Execution Audit Log Entity (`ZMDQ_EXECUTION_LOG`)
- `EXECUTION_ID`: Execution GUID.
- `UNAME`: Executing SAP User.
- `DATUM` & `UZEIT`: Run Timestamp.
- `TOTAL_RECORDS`: Count of master data records evaluated.
- `GLOBAL_SCORE`: Final calculated completeness score.
- `FINDINGS_COUNT`: Total count of quality findings detected.
