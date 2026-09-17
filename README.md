# SAP Master Data Quality Checker

> An enterprise-grade master data audit, quality scoring, duplicate detection, and completeness analysis framework built for both **SAP R/3 (ECC / Oracle DB)** and **SAP S/4HANA (HANA DB / CDS / Fiori)** environments.

---

## 1. Overview & Purpose

**SAP Master Data Quality Checker** addresses one of the most critical operational challenges in SAP enterprise landscapes: **poor master data quality**. Incomplete, inconsistent, or duplicated master data directly causes order processing failures, logistics bottlenecks, migration delays, financial reporting errors, and elevated operational costs.

This framework empowers SAP Functional Consultants, Data Migration Engineers, MDG Consultants, and Developers to:
- Audit master data across **MM (Material Master)**, **SD (Customer Master)**, **FI (Accounting Data)**, **Procurement (Vendor Master)**, and **S/4HANA (Business Partners)**.
- Compute multi-level **Completeness & Quality Scores** (Record Level, Business Object Level, and Global SAP Instance Level).
- Detect potential **duplicate entries** using exact Tax ID matches and Levenshtein distance fuzzy matching algorithms.
- Maintain **configurable business rules** without hardcoding logic in programs.
- Provide actionable findings with explicit root causes and remediation guidance.
- Operate seamlessly in **100% offline environments** using Dependency Injection and mock datasets.

---

## 2. Technical Stack & Standards

| Domain | Technology / Specification |
| :--- | :--- |
| **Language & Paradigm** | Clean ABAP, ABAP Objects (OO), SAPUI5 / Fiori Elements |
| **Architecture** | Layered Separation of Concerns (Presentation, Service, Domain, Repository) |
| **Principles** | SOLID, DRY, KISS, YAGNI, Low Coupling, High Cohesion |
| **Database Compatibility** | Classic Open SQL (`FOR ALL ENTRIES IN` for Oracle/SQL Server DBs) & SAP S/4HANA HANA DB Pushdown (CDS Views) |
| **Security & Logging** | Explicit `AUTHORITY-CHECK` (`M_MATE_STA`, `V_VBAK_VKO`, `F_BKPF_BUK`, `B_BUPA_GRP`), SAP Application Log (`BAL_LOG_*`) |
| **Execution** | Online, Batch, Simulation Mode, Read-Only |
| **Testing** | ABAP Unit (`ZCL_MDQ_*_TEST`), Mock Repositories (`ZCL_MDQ_REPO_MOCK`), JSON Mock Datasets |

---

## 3. High-Level Architecture

```text
+------------------------------------------------------------------------------+
| PRESENTATION LAYER                                                           |
|  - R/3 / ECC: SALV Interactive Grid Reports (ZCL_MDQ_REPORT_SALV)            |
|  - S/4HANA: SAPUI5 / Fiori Elements Analytical Dashboard (frontend/ui5)      |
+------------------------------------------------------------------------------+
                                      |
                                      v
+------------------------------------------------------------------------------+
| APPLICATION & SERVICE LAYER                                                  |
|  - Orchestrator: ZCL_MDQ_REPORT_SERVICE                                      |
|  - Authorization Manager: ZCL_MDQ_AUTH_SERVICE                               |
|  - Export Manager: ZCL_MDQ_EXPORT_SERVICE                                    |
+------------------------------------------------------------------------------+
                                      |
                                      v
+------------------------------------------------------------------------------+
| DOMAIN & BUSINESS LOGIC LAYER                                                |
|  - Quality Rule Engine: ZCL_MDQ_RULE_ENGINE                                  |
|  - Scoring Engine: ZCL_MDQ_SCORING_ENGINE                                    |
|  - Duplicate Engine: ZCL_MDQ_DUPLICATE_ENGINE (Levenshtein Distance Engine)   |
+------------------------------------------------------------------------------+
                                      |
                                      v
+------------------------------------------------------------------------------+
| DATA ACCESS & REPOSITORY LAYER (Dependency Injection via ZIF_MDQ_REPOSITORY) |
|  - Production Repo (SAP Live DB): ZCL_MDQ_REPOSITORY                         |
|  - Offline Mock Repo (Simulation Mode): ZCL_MDQ_REPO_MOCK                    |
+------------------------------------------------------------------------------+
```

---

## 4. Functional Capabilities

### 📦 Material Master (MM) Validation
- `FR-001`: Detect materials missing descriptions (`MAKT-MAKTX`).
- `FR-002`: Detect materials missing base unit of measure (`MARA-MEINS`).
- `FR-003`: Detect materials missing material group (`MARA-MATKL`).
- `FR-004`: Detect materials without plant assignment (`MARC`).
- `FR-005`: Detect materials missing sales views (`MVKE`).
- `FR-006` to `FR-010`: Detect blocked, obsolete, unclassified materials, or missing weights/dimensions.

### 👤 Customer Master (SD / FI) Validation
- `FR-011`: Detect customers missing name (`KNA1-NAME1`).
- `FR-012`: Detect customers missing street/city/postal code (`KNA1-STRAS`, `KNA1-ORT01`).
- `FR-013`: Detect customers missing country (`KNA1-LAND1`).
- `FR-014`: Detect customers missing Tax ID / VAT Registration (`KNA1-STCD1` / `STCEG`).
- `FR-015` to `FR-020`: Detect missing payment terms, sales org assignment, email address, or blocks.

### 🏭 Vendor Master (Procurement / FI) Validation
- `FR-021`: Detect vendors missing Tax ID (`LFA1-STCD1`).
- `FR-022`: Detect vendors missing payment terms / bank details (`LFB1-ZTERM`).
- `FR-023`: Detect vendors missing address information.
- `FR-024` to `FR-028`: Detect duplicate vendors, blocks, missing purchasing org data, or email.

### 🔍 Business Partner (S/4HANA MDG) Validation
- Audit unified Business Partner tables (`BUT000`, `BUT020`, `BUT0ID`) for S/4HANA migration readiness.

---

## 5. Duplicate Detection Engine & Levenshtein Distance Strategy

To identify duplicate entries created by spelling variations, abbreviations, or missing spaces, the class `ZCL_MDQ_DUPLICATE_ENGINE` implements a multi-pass duplicate detection algorithm driven by normalized **Levenshtein Distance**:

$$\text{Similarity (\%)} = \left( 1 - \frac{\text{Levenshtein}(S_1, S_2)}{\max(\text{len}(S_1), \text{len}(S_2))} \right) \times 100$$

### Detection Passes & Thresholds:
1. **Exact Tax ID Match (`100%`)**: Matches identical Tax IDs / NIFs (`STCD1` / `STCEG`) across Customer / Vendor records.
2. **Fuzzy Corporate Name Match (`70% - 99%`)**: Computes Levenshtein distance on normalized company names (`NAME1`).
3. **Fuzzy Address Match (`75% - 99%`)**: Computes distance on combined Street + Postal Code (`STRAS` + `PSTLZ`).
4. **Fuzzy Material Description Match (`70% - 99%`)**: Computes distance on material descriptions (`MAKTX`) sharing the same Material Group (`MATKL`).

---

## 6. Repository Structure

```text
SAP-master-data-quality-checker/
├── .agents/                        # Agent governance & project guidelines
├── docs/                           # Detailed architecture, flows, data model, security specs
├── abap/                           # Production ABAP OO classes, interfaces & unit tests
│   ├── ZIF_MDQ_CONSTANTS.intf.abap
│   ├── ZIF_MDQ_REPOSITORY.intf.abap
│   ├── ZIF_MDQ_RULE_ENGINE.intf.abap
│   ├── ZIF_MDQ_SCORING_ENGINE.intf.abap
│   ├── ZIF_MDQ_DUPLICATE_ENGINE.intf.abap
│   ├── ZCL_MDQ_REPOSITORY.clas.abap
│   ├── ZCL_MDQ_REPO_MOCK.clas.abap
│   ├── ZCL_MDQ_RULE_ENGINE.clas.abap
│   ├── ZCL_MDQ_RULE_ENGINE_TEST.clas.abap
│   ├── ZCL_MDQ_SCORING_ENGINE.clas.abap
│   ├── ZCL_MDQ_SCORING_ENGINE_TEST.clas.abap
│   ├── ZCL_MDQ_DUPLICATE_ENGINE.clas.abap
│   ├── ZCL_MDQ_DUPLICATE_ENGINE_TEST.clas.abap
│   ├── ZCL_MDQ_REPORT_SERVICE.clas.abap
│   ├── ZCL_MDQ_AUTH_SERVICE.clas.abap
│   ├── ZCL_MDQ_EXPORT_SERVICE.clas.abap
│   └── CX_MDQ_QUALITY_ERROR.clas.abap
├── data/                           # Mock datasets for 100% offline verification
├── frontend/                       # SAPUI5 / Fiori Elements dashboard
├── integration/                    # S/4HANA CDS Views & OData definition
├── REQUIREMENTS.md                 # Full business & technical requirements
├── project_architecture.txt        # E2E system architecture description
└── project_file_system.txt         # Repository folder tree & layout
```

---

## 7. Development & Offline Mock Execution

Because development is conducted in a greenfield environment without an active SAP ERP instance:
1. **Dependency Injection**: Business logic classes request `ZIF_MDQ_REPOSITORY`.
2. **Mock Repository (`ZCL_MDQ_REPO_MOCK`)**: Reads JSON mock datasets from `data/mock_*.json`.
3. **ABAP Unit Validation**: Unit tests (`ZCL_MDQ_RULE_ENGINE_TEST`, `ZCL_MDQ_SCORING_ENGINE_TEST`, `ZCL_MDQ_DUPLICATE_ENGINE_TEST`) evaluate rule thresholds, scoring deductions, and fuzzy matching 100% offline.

---

## 8. License & Compliance

This project is licensed under the Apache 2.0 License. It strictly adheres to SAP standard naming conventions, SAP Security guidelines, and Clean ABAP principles.
