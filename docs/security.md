# Security, Authorization & Logging Specification

> Authorization objects, security controls, SAP Application Logging (`BAL_LOG_*` / `CL_BALI_LOGGER`), and privacy protection standards.

---

## 1. SAP Authorization Check Specification

To adhere strictly to SAP security standards, no master data query can execute without explicit user authorization checks.

### 1.1 Material Master (MM) Authorization Objects
- **Object**: `M_MATE_STA` (Material Master Maintenance Status)
  - `ACTVT`: `'03'` (Display)
  - `STATM`: `'K'` (Basic Data), `'V'` (Sales Data), `'D'` (MRP/Plant Data)
- **Object**: `M_MATE_WRK` (Material Master Plant Authorization)
  - `ACTVT`: `'03'` (Display)
  - `WERKS`: Plant selection range

### 1.2 Customer Master (SD / FI) Authorization Objects
- **Object**: `V_VBAK_VKO` (Sales Organization Authorization)
  - `ACTVT`: `'03'` (Display)
  - `VKORG`: Sales Organization selection range
- **Object**: `F_BKPF_BUK` (Company Code Authorization)
  - `ACTVT`: `'03'` (Display)
  - `BUKRS`: Company Code selection range

### 1.3 Vendor Master (Procurement / FI) Authorization Objects
- **Object**: `M_BEST_EKO` (Purchasing Organization Authorization)
  - `ACTVT`: `'03'` (Display)
  - `EKORG`: Purchasing Organization selection range
- **Object**: `F_BKPF_BUK` (Company Code Authorization)
  - `ACTVT`: `'03'` (Display)
  - `BUKRS`: Company Code selection range

### 1.4 Business Partner (S/4HANA BP) Authorization Objects
- **Object**: `B_BUPA_GRP` (Business Partner Authorization Group)
  - `ACTVT`: `'03'` (Display)
  - `RLTYP`: Business Partner Role

---

## 2. SAP Application Logging Architecture

Auditability and execution history are maintained via standard SAP Application Log transactions (`SLG1` / `SLG0`):
- **Object Name**: `ZMDQ` (Master Data Quality Checker)
- **Subobject Name**: `RUN` (Execution Audit Runs)

In classic R/3 environments, logging is handled via function modules (`BAL_LOG_CREATE`, `BAL_LOG_MSG_ADD`, `BAL_DB_SAVE`).  
In modern S/4HANA environments, logging can utilize `CL_BALI_LOGGER`.

---

## 3. Data Protection & Read-Only Guarantee (NFR-004 & NFR-005)

- The tool operates strictly in **Read-Only** mode. No `UPDATE`, `INSERT`, `MODIFY`, or `DELETE` statements are ever executed against SAP master data tables (`MARA`, `KNA1`, `LFA1`, `BUT000`).
- No sensitive personal data (e.g., bank account passwords, Tax IDs in unencrypted raw logs) is stored in persistent logs.
