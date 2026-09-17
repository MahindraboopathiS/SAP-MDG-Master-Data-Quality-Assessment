# Functional Flow & Execution Workflow Specification

> Comprehensive execution workflow, rule evaluation process, and score calculation lifecycle for **SAP Master Data Quality Checker**.

---

## 1. End-to-End Functional Flow

```text
[ 1. User Input & Selection Screen ]
   - Select Business Objects (Materials, Customers, Vendors, Business Partners)
   - Selection Filters (Plant, Sales Org, Company Code, Date Range)
   - Execution Mode (Online ALV / Batch / JSON Output)
   - Repository Selection (Live SAP DB / Offline Mock Engine)
                  |
                  v
[ 2. SAP Authorization Verification ]
   - Execute AUTHORITY-CHECK for selected business domains
   - Filter out unauthorized organizational units
                  |
                  v
[ 3. Master Data Retrieval ]
   - Fetch header & item tables (MARA/MAKT/MARC, KNA1/KNB1/KNVV, LFA1/LFB1, BUT000)
   - Read active Quality Rules configuration (ZMDQ_RULE)
                  |
                  v
[ 4. Quality Rule Evaluation Engine ]
   - Execute active functional checks (FR-001 through FR-028)
   - Generate granular Validation Results per record and field
                  |
                  v
[ 5. Quality Score & Duplicate Calculation ]
   - Compute record completeness score (%)
   - Aggregate score by Business Object & Global Instance
   - Execute fuzzy string and Tax ID duplicate matching algorithms
                  |
                  v
[ 6. Presentation & Export Engine ]
   - Render Interactive SALV Grid or Fiori Dashboard
   - Log execution audit trail via SAP Application Log (BAL_LOG_*)
   - Provide Excel / CSV export options
```

---

## 2. Quality Score Classification Matrix

Scores are computed as a percentage:
$$\text{Quality Score (\%)} = 100 - \left( \frac{\sum \text{Severity Deductions}}{\text{Total Configured Weight}} \times 100 \right)$$

| Score Range | Classification Band | Risk Level | Operational Impact |
| :---: | :---: | :---: | :---: |
| **95% - 100%** | **Excellent** | Very Low | Fully compliant with business standards. Ready for S/4HANA migration. |
| **85% - 94%** | **Good** | Low | Minor non-critical fields missing. No logistics blocker. |
| **70% - 84%** | **Fair** | Medium | Incomplete tax or accounting data. Potential EDI or billing delay. |
| **50% - 69%** | **Poor** | High | Missing organizational assignments or missing addresses. High operational friction. |
| **0% - 49%** | **Critical** | Extremely High | Severe data corruption or missing primary keys. Process failure imminent. |

---

## 3. Duplicate Detection Strategy

Duplicate detection relies on multi-pass field comparisons:
1. **Pass 1 - Exact Tax ID Match**: Same Tax ID (`STCD1` / `STCEG`) across multiple Customer / Vendor records.
2. **Pass 2 - Fuzzy Name & Address Match**: Levenshtein distance on Name + Street + Postal Code.
3. **Pass 3 - Material Description Similarity**: Tokenized comparison of `MAKTX` strings across same Material Group (`MATKL`).
