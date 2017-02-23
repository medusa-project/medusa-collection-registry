initialize_data_table("table#assessments", {});
initialize_data_table("table#attachments", {});
initialize_data_table("table#file_groups", {
  "order": [
    [2, "asc"],
    [0, "desc"]
  ]
});
initialize_data_table("table#collections", {
  "order": [
    [3, "asc"]
  ]
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

  object_level: function () {
    this.filter('object-level store');
  },

  filter: function (filter_string) {
    $('#file_groups').DataTable().columns(2).search(filter_string).draw();
  }
};