initialize_data_table("table#assessments", {});
initialize_data_table("table#attachments", {});
initialize_data_table("table#file_groups", {
  "aaSorting": [
    [0, "desc"]
  ]
});
initialize_data_table("table#collections", {
  "aaSorting": [
    [3, "asc"]
  ]
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