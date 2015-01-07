initialize_data_table("table#assessments");
initialize_data_table("table#attachments");
$(function () {
  $("table#file_groups").dataTable({
    "aaSorting": [
      [0, "desc"]
    ],
    "aLengthMenu": [
      [10, 25, 50, 100, -1],
      [10, 25, 50, 100, "All"]
    ],
    "language": {
      "search": "Filter results: "
    }
  })
});
$(function () {
  var table = $('table#collections').dataTable({
    "aaSorting": [
      [3, "asc"]
    ],
    "iDisplayLength": 25,
    "aLengthMenu": [
      [10, 25, 50, 100, -1],
      [10, 25, 50, 100, "All"]
    ],
    "bStateSave": "true",
    "fnStateSave": function (oSettings, oData) {
      localStorage.setItem('DataTables_' + window.location.pathname, JSON.stringify(oData));
    },
    "fnStateLoad": function (oSettings) {
      return JSON.parse(localStorage.getItem('DataTables_' + window.location.pathname));
    },
    "language": {
      "search": "Filter results: "
    }
  });
  if (table) {
    //table.fnSetColumnVis(1, true);
  }
});

function toggle_uuid() {
  var table = $('table#collections').dataTable();
  if (table) {
    var isVisible = table.fnSettings().aoColumns[1].bVisible;
    //table.fnSetColumnVis(1, true)
  }
}

var storage_level_filter = {
  all: function () {
    this.filter('');
  },

  external: function () {
    this.filter('external');
  },

  bit_level: function () {
    this.filter('bit-level store');
  },

  object_level: function () {
    this.filter('object-level store');
  },

  filter: function (filter_string) {
    $('#file_groups').dataTable().fnFilter(filter_string, 2)
  }
};