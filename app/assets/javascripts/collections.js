initialize_data_table("table#collections");
initialize_data_table("table#assessments");
initialize_data_table("table#attachments");
$(document).ready(function () {
  $("table#file_groups").dataTable({
    "aaSorting":[
      [0, "desc"]
    ]
  })
})

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