var default_datatable_args = {
  "aaSorting": [
    [0, "asc"]
  ],
  "aLengthMenu": [
    [10, 25, 50, 100, -1],
    [10, 25, 50, 100, "All"]
  ],
  "iDisplayLength": 25,
  "bStateSave": "true",
  "fnStateSave": function (oSettings, oData) {
    localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(oData));
  },
  "fnStateLoad": function (oSettings) {
    return JSON.parse(localStorage.getItem('DataTables_' + window.location.pathname));
  },
  "language": {
    "search": "Filter results: ",
    "paginate": {
      "next": "<i class='fa fa-chevron-right' title='next'><\i>",
      "previous": "<i class='fa fa-chevron-left' title='previous'><\i>"
    }
  }
};

//Make the table selected by the provided CSS selector into a dataTables table using the default_datatable_args with
//the extra_args deep merged in.
function initialize_data_table(tableSelector, extra_args) {
  var args = $.extend(true, {}, default_datatable_args, extra_args)
  $(function () {
    $(tableSelector).dataTable(args)
  })
};
