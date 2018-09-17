var default_datatable_args = {
  'dom': "<'row'<'col-sm-2'l><'col-sm-4'B><'col-sm-6'f>>" + "<'row'<'col-sm-12'tr>>" + "<'row'<'col-sm-5'i><'col-sm-7'p>>",
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
  },
  "processing": true,
  "pagingType": 'full_numbers',
  'buttons': [],
  "columnDefs": [
    {'type' : "diacritics-neutralise", 'targets' : '_all'}
  ]
};

//Make the table selected by the provided CSS selector into a dataTables table using the default_datatable_args with
//the extra_args deep merged in.
function initialize_data_table(tableSelector, extra_args) {
  $(function () {
    initialize_data_table_synchronous(tableSelector, extra_args);
  })
};

function initialize_data_table_synchronous(tableSelector, extra_args) {
  var args = $.extend(true, {}, default_datatable_args, extra_args);
  //console.log(args);
  try {
    var table = $(tableSelector).DataTable(args);
    //table.state.clear();
    add_back_to_top_button(tableSelector);
    $('input[type="search"]').keyup( function () {
      table
          .search(
              jQuery.fn.DataTable.ext.type.search.string( this.value )
          )
          .draw();
      //console.log('Did search');
    } );
    //console.log("Initialized " + tableSelector);
  } catch (err) {
    //console.log("Error initializing " + tableSelector);
  }
}

//Add a back to top of page button to the datatable
function add_back_to_top_button(tableSelector) {
  var pagination_list = $(tableSelector).closest('div.row').next('div').find('ul.pagination');
  var up_button = '<li class="paginate_button"><a href="#global-navigation"><i class="fa fa-chevron-circle-up"></i></a></li>';
  pagination_list.append(up_button);
  console.log("Added top button " + tableSelector);
}
