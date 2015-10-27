var default_datatable_args = {
  "order": [
    [0, "asc"]
  ],
  "lengthMenu": [
    [10, 25, 50, 100, -1],
    [10, 25, 50, 100, "All"]
  ],
  "pageLength": 25,
  "stateSave": "true",
  "stateSaveCallback": function (settings, data) {
    localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(data));
  },
  "stateLoadCallback": function (settings) {
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
  var args = $.extend(true, {}, default_datatable_args, extra_args);
  $(function () {
    try {
      $(tableSelector).DataTable(args);
      add_back_to_top_button(tableSelector);
    } catch(err) {

    }
  })
};

//Add a back to top of page button to the datatable
function add_back_to_top_button(tableSelector) {
  var pagination_list = $(tableSelector).closest('div.row').next('div').find('ul.pagination');
  var up_button = '<li class="paginate_button"><a href="#global-navigation"><i class="fa fa-chevron-circle-up"></i></a></li>';
  pagination_list.append(up_button);
}
