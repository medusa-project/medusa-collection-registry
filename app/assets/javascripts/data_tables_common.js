//Make the table selected by the provided CSS selector into a dataTables table, sorted by
//the first column
function initialize_data_table(tableSelector) {
  $(function () {
    $(tableSelector).dataTable({
      "aaSorting": [
        [0, "asc"]
      ],
      "iDisplayLength": 25,
      "bStateSave": "true",
      "fnStateSave": function (oSettings, oData) {
        localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(oData));
      },
      "fnStateLoad": function (oSettings) {
        return JSON.parse(localStorage.getItem('DataTables_' + window.location.pathname));
      }
    })
  })
};
