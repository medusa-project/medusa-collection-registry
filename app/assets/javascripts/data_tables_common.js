//Make the table selected by the provided CSS selector into a dataTables table, sorted by
//the first column
function initialize_data_table(tableSelector) {
  $(function () {
    $(tableSelector).dataTable({
      "aaSorting":[
        [0, "asc"]
      ],
      "iDisplayLength": 25
    })
  })
};
