# Architecture & Software Engineering Specification

> Technical architecture, layer decoupling, dependency injection, and SAP database compatibility strategy for **SAP Master Data Quality Checker**.

---

## 1. Architectural Strategy

The framework implements a strict **4-Tier Layered Architecture** with unidirectional dependencies down to abstractions.

```text
[ Presentation Layer: SALV Grid / Fiori UI5 ]
                    |
                    v
[ Service Orchestrator: ZCL_MDQ_REPORT_SERVICE ]
                    |
      +-------------+-------------+
      |                           |
      v                           v
[ Domain Engines ]       [ Authorization Service ]
  - ZCL_MDQ_RULE_ENGINE    - ZCL_MDQ_AUTH_SERVICE
  - ZCL_MDQ_SCORING_ENGINE
  - ZCL_MDQ_DUPLICATE_ENGINE
      |
      v
[ Data Repository Interface: ZIF_MDQ_REPOSITORY ]
      |
      +---------------------------+
      |                           |
      v                           v
[ Live SAP DB Repo ]     [ Offline Mock Repo ]
  ZCL_MDQ_REPOSITORY       ZCL_MDQ_REPO_MOCK
```

---

## 2. Dependency Injection & Offline Strategy

To allow execution and testing without a live SAP ERP instance:
- All domain engines depend exclusively on the interface `ZIF_MDQ_REPOSITORY`.
- In production runtime, `ZCL_MDQ_REPOSITORY` reads standard SAP tables (`MARA`, `MAKT`, `KNA1`, `LFA1`, `BUT000`).
- In offline execution / ABAP Unit mode, `ZCL_MDQ_REPO_MOCK` is injected to supply mock records from JSON datasets (`data/mock_*.json`).

---

## 3. Database Compatibility & Optimization

### Classic R/3 / ECC (Oracle DB, SQL Server, DB2)
- All Open SQL queries use `FOR ALL ENTRIES IN` to prevent nested `SELECT` statements inside `LOOP ... ENDLOOP` blocks.
- Explicit field lists are selected (no `SELECT *`).

### SAP S/4HANA (HANA DB)
- Code leverages SAP HANA DB Pushdown capabilities.
- Heavy aggregation and filtering can be pushed down to Core Data Services (CDS Views: `ZI_MDQ_MaterialQuality`, `ZI_MDQ_CustomerQuality`, `ZI_MDQ_VendorQuality`, `ZI_MDQ_BusinessPartnerQuality`).

---

## 4. Class & Interface Taxonomy

- `ZIF_MDQ_CONSTANTS`: Defines severity levels (Critical, High, Medium, Low), object types (MAT, CUST, VEND, BP), and rating bands.
- `ZIF_MDQ_REPOSITORY`: ABAP OO interface defining data access contracts for master data and quality rules.
- `ZCL_MDQ_RULE_ENGINE`: Evaluates master data records against active business rules configured in `ZMDQ_RULE`.
- `ZCL_MDQ_SCORING_ENGINE`: Computes completeness score percentages and maps them to qualitative bands (*Excellent*, *Good*, *Fair*, *Poor*, *Critical*).
- `ZCL_MDQ_DUPLICATE_ENGINE`: Evaluates exact and fuzzy duplicate matches on key fields (e.g., Tax ID, Name + Postal Code, Material Description).
- `ZCL_MDQ_REPORT_SERVICE`: Coordinates authorization checks, data retrieval, rule evaluation, score computation, and reporting output.
