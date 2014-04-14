initialize_data_table("table#assessments");
initialize_data_table("table#attachments");
$(function () {
  $("table#file_groups").dataTable({
    "aaSorting":[
      [0, "desc"]
    ]
  })
});
$(function () {
  $('table#collections').dataTable({
    "aaSorting": [
      [1, "asc"]
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
});

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

  object_level: function() {
    this.filter('object-level store');
  },

  filter: function(filter_string) {
    $('#file_groups').dataTable().fnFilter(filter_string, 2)
  }
};