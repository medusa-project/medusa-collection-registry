initialize_data_table("table#collections");
initialize_data_table("table#assessments");
initialize_data_table("table#file_groups");
initialize_data_table("table#attachments");

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