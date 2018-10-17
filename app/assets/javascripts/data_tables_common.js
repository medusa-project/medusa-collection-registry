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
};

//Make the table selected by the provided CSS selector into a dataTables table using the default_datatable_args with
//the extra_args deep merged in.
function initialize_data_table(tableSelector, extra_args) {
  $(function () {
    initialize_data_table_synchronous(tableSelector, extra_args);
  })
};

function initialize_data_table_synchronous(tableSelector, extra_args) {
  //Bail out if already a datatable
  if ($.fn.DataTable.fnIsDataTable($(tableSelector))) {
    return;
  }
  var args = $.extend(true, {}, default_datatable_args, extra_args);
  try {
    let table = $(tableSelector).DataTable(args);
    let input = $('input[type="search"]', $(tableSelector).closest('div.row').prev('div.row'));
    ensure_back_to_top_button(tableSelector);
    let search = function (string) {
      table
          .search(
              jQuery.fn.DataTable.ext.type.search.string(string)
          )
          .draw();
      ensure_back_to_top_button(tableSelector);
    };
    $(input).keyup(function () {
      search(this.value);
    });
    //This seems more complicated than it should, but as I understand, the event fires immediately,
    //and possibly before the text is actually present in the input element. So this sort of workaround
    //is needed. The setTimeout sends this to the bottom of the stack and forces the content to be pasted
    //before. Now, I'm not sure why just extracting the text and doing the search doesn't work - but it
    //doesn't. It's not worth fighting.
    $(input).on("paste", function (e) {
      let text = e.originalEvent.clipboardData.getData('text');
      setTimeout(function () {
        search(text);
      }, 0);
    });
  } catch (err) {
    console.log("Error initializing " + tableSelector);
  }
}

//TODO - figure out how to do this correctly so that the button survives
//redraws of the table, e.g. when search happens.
//Add a back to top of page button to the datatable
function ensure_back_to_top_button(tableSelector) {
  let pagination_list = $(tableSelector).closest('div.row').next('div').find('ul.pagination');
  if (!$('li.paginate_button', pagination_list)) {
    let up_button = '<li class="paginate_button"><a href="#global-navigation"><i class="fa fa-chevron-circle-up"></i></a></li>';
    pagination_list.append(up_button);
  }
}

