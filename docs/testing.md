# Testing & Offline Verification Strategy Specification

> ABAP Unit test architecture, mock repository implementation, and 100% offline verification harness for **SAP Master Data Quality Checker**.

---

## 1. Testing Rationale & Philosophy

Because this project is built in a greenfield environment without access to a live SAP ERP instance (R/3 or S/4HANA), **automated offline unit testing** is a non-negotiable architectural requirement.

The framework guarantees **100% testability offline** via Dependency Injection (DI) and ABAP Unit test suites.

---

## 2. ABAP Unit Suite Structure

```text
[ ABAP Unit Test Suite: ZCL_MDQ_RULE_ENGINE_TEST ]
                 |
                 +--> Instantiate ZCL_MDQ_REPO_MOCK
                 |
                 +--> Inject Mock Repository into ZCL_MDQ_RULE_ENGINE
                 |
                 +--> Execute Rule Engine Methods:
                 |      - test_material_missing_description()
                 |      - test_customer_missing_tax_id()
                 |      - test_vendor_duplicate_detection()
                 |      - test_score_calculation_banding()
                 |
                 +--> Assert via cl_abap_unit_assert:
                        - assert_equals()
                        - assert_subrc()
                        - assert_bound()
```

---

## 3. Mock Repository Design (`ZCL_MDQ_REPO_MOCK`)

The mock repository class `ZCL_MDQ_REPO_MOCK` implements `ZIF_MDQ_REPOSITORY` and provides pre-populated, deterministic mock data tables representing SAP standard master data:
- `MARA` / `MAKT` / `MARC` mock records (including incomplete records, missing descriptions, unassigned plants).
- `KNA1` / `KNB1` / `KNVV` mock records (including missing Tax IDs, missing street/city, blocked customers).
- `LFA1` / `LFB1` / `LFM1` mock records (including duplicate tax IDs, missing payment terms).
- `BUT000` / `BUT020` mock records for S/4HANA Business Partners.
- `ZMDQ_RULE` active quality rules configuration dataset.

---

## 4. Quality Gate Criteria

All ABAP OO modules must fulfill the following quality criteria:
- **Zero Syntax Errors / Zero Linter Warnings**.
- **100% ABAP Unit Test Pass Rate**.
- **Class-based Exception Safety**: All errors must throw `CX_MDQ_QUALITY_ERROR` without unhandled runtime short dumps (`ST22`).
