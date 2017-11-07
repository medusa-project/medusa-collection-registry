$(document).ready(function () {
  initialize_data_table_synchronous("table#file_formats", {
      'dom': "<'row'<'col-sm-2'l><'col-sm-4'B><'col-sm-6'f>>" + "<'row'<'col-sm-12'tr>>" + "<'row'<'col-sm-5'i><'col-sm-7'p>>",
      'buttons': ['csv'],
  });
})
