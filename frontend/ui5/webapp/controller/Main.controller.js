sap.ui.define([
  "sap/ui/core/mvc/Controller",
  "sap/ui/model/Filter",
  "sap/ui/model/FilterOperator",
  "sap/m/MessageToast"
], function (Controller, Filter, FilterOperator, MessageToast) {
  "use strict";

  return Controller.extend("sap.mdq.checker.controller.Main", {
    onInit: function () {
      // Controller initialization
    },

    onSearchScores: function (oEvent) {
      var sQuery = oEvent.getParameter("query");
      var aFilters = [];
      if (sQuery && sQuery.length > 0) {
        aFilters.push(new Filter("objectKey", FilterOperator.Contains, sQuery));
      }
      var oTable = this.byId("scoresTable");
      var oBinding = oTable.getBinding("items");
      oBinding.filter(aFilters);
    },

    onFilterSeverity: function (oEvent) {
      var sKey = oEvent.getParameter("selectedItem").getKey();
      var aFilters = [];
      if (sKey !== "ALL") {
        aFilters.push(new Filter("severity", FilterOperator.EQ, sKey));
      }
      var oTable = this.byId("findingsTable");
      var oBinding = oTable.getBinding("items");
      oBinding.filter(aFilters);
    },

    onExportCSV: function () {
      var oModel = this.getView().getModel();
      var aFindings = oModel.getProperty("/findings");
      
      var sCsv = "OBJECT_TYPE,OBJECT_KEY,RULE_ID,SEVERITY,FIELD_NAME,MESSAGE\n";
      aFindings.forEach(function(f) {
        sCsv += f.objectType + "," + f.objectKey + "," + f.ruleId + "," + f.severity + "," + f.fieldName + ",\"" + f.message + "\"\n";
      });

      var blob = new Blob([sCsv], { type: "text/csv;charset=utf-8;" });
      var link = document.createElement("a");
      link.href = URL.createObjectURL(blob);
      link.setAttribute("download", "master_data_quality_findings.csv");
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      MessageToast.show("CSV Export downloaded successfully!");
    },

    onExportExcel: function () {
      MessageToast.show("Excel Export triggered!");
    }
  });
});
