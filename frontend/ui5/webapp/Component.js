sap.ui.define([
  "sap/ui/core/UIComponent",
  "sap/ui/model/json/JSONModel"
], function (UIComponent, JSONModel) {
  "use strict";

  return UIComponent.extend("sap.mdq.checker.Component", {
    metadata: {
      manifest: "json"
    },

    init: function () {
      // Call standard UIComponent init
      UIComponent.prototype.init.apply(this, arguments);

      // Initialize default data model
      var oData = {
        summary: {
          globalScore: 84.50,
          globalRating: "FAIR",
          totalRecords: 11,
          totalFindings: 18,
          criticalFindings: 4,
          highFindings: 8,
          totalDuplicates: 3
        },
        scores: [
          { objectType: "MAT", objectKey: "000000000000001001", score: 100, ratingBand: "EXCELLENT", findingsCount: 0 },
          { objectType: "MAT", objectKey: "000000000000001002", score: 35, ratingBand: "CRITICAL", findingsCount: 4 },
          { objectType: "MAT", objectKey: "000000000000001003", score: 65, ratingBand: "POOR", findingsCount: 3 },
          { objectType: "MAT", objectKey: "000000000000001004", score: 100, ratingBand: "EXCELLENT", findingsCount: 0 },
          { objectType: "CUST", objectKey: "0000100001", score: 100, ratingBand: "EXCELLENT", findingsCount: 0 },
          { objectType: "CUST", objectKey: "0000100002", score: 25, ratingBand: "CRITICAL", findingsCount: 5 },
          { objectType: "CUST", objectKey: "0000100003", score: 90, ratingBand: "GOOD", findingsCount: 1 },
          { objectType: "VEND", objectKey: "0000200001", score: 100, ratingBand: "EXCELLENT", findingsCount: 0 },
          { objectType: "VEND", objectKey: "0000200002", score: 45, ratingBand: "CRITICAL", findingsCount: 4 },
          { objectType: "BP", objectKey: "0000300001", score: 100, ratingBand: "EXCELLENT", findingsCount: 0 },
          { objectType: "BP", objectKey: "0000300002", score: 70, ratingBand: "FAIR", findingsCount: 1 }
        ],
        findings: [
          { objectType: "MAT", objectKey: "000000000000001002", ruleId: "FR-001", severity: "CRITICAL", fieldName: "MAKTX", message: "Material missing description (MAKT-MAKTX)" },
          { objectType: "MAT", objectKey: "000000000000001002", ruleId: "FR-002", severity: "CRITICAL", fieldName: "MEINS", message: "Material missing Base Unit of Measure (MARA-MEINS)" },
          { objectType: "MAT", objectKey: "000000000000001002", ruleId: "FR-004", severity: "HIGH", fieldName: "WERKS", message: "Material not assigned to any Plant (MARC-WERKS)" },
          { objectType: "MAT", objectKey: "000000000000001002", ruleId: "FR-005", severity: "MEDIUM", fieldName: "VKORG", message: "Material missing Sales Organization data (MVKE-VKORG)" },
          { objectType: "CUST", objectKey: "0000100002", ruleId: "FR-011", severity: "CRITICAL", fieldName: "NAME1", message: "Customer missing Name (KNA1-NAME1)" },
          { objectType: "CUST", objectKey: "0000100002", ruleId: "FR-013", severity: "CRITICAL", fieldName: "LAND1", message: "Customer missing Country code (KNA1-LAND1)" },
          { objectType: "CUST", objectKey: "0000100002", ruleId: "FR-014", severity: "HIGH", fieldName: "STCD1", message: "Customer missing Tax ID (KNA1-STCD1)" },
          { objectType: "CUST", objectKey: "0000100002", ruleId: "FR-017", severity: "HIGH", fieldName: "SPERR", message: "Customer is posted with Central Posting Block" },
          { objectType: "VEND", objectKey: "0000200002", ruleId: "FR-021", severity: "HIGH", fieldName: "STCD1", message: "Vendor missing Tax ID (LFA1-STCD1)" },
          { objectType: "VEND", objectKey: "0000200002", ruleId: "FR-025", severity: "HIGH", fieldName: "SPERR", message: "Vendor is posted with Central Posting Block" }
        ],
        duplicates: [
          { objectType: "CUST", primaryKey: "0000100001", matchKey: "0000100003", similarity: "100.00", matchType: "EXACT_TAX_ID", details: "Duplicate Tax ID (30112233445) shared between customers 100001 and 100003" },
          { objectType: "CUST", primaryKey: "0000100001", matchKey: "0000100003", similarity: "88.24", matchType: "FUZZY_NAME", details: "Fuzzy Name match (88.24%) between ACME Corporation SA and Acme Corp S.A." },
          { objectType: "MAT", primaryKey: "000000000000001001", matchKey: "000000000000001004", similarity: "100.00", matchType: "EXACT_DESCRIPTION", details: "Duplicate Material Description ('Industrial Water Pump 500W') shared between 1001 and 1004" }
        ]
      };

      var oModel = new JSONModel(oData);
      this.setModel(oModel);
    }
  });
});
