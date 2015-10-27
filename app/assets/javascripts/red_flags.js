$.extend($.fn.dataTableExt.oSort, {
  "priority-pre": function (a) {
    var priorities = {"high": 2, "medium": 1, "low": 0};
    return priorities[a];
  },
  "priority-asc": function (a, b) {
    return ((a < b) ? -1 : ((a > b) ? 1 : 0));
  },
  "priority-desc": function (a, b) {
    return -(this["priority-asc"](a, b));
  }
});

initialize_data_table('table#red-flags-table', {
  "columns": [null, null, {"type": 'priority'}, null, null, null, null],
  "order": [
    [3, "asc"],
    [2, "desc"]
  ]
});

var red_flag_filter = {
  all: function () {
    this.filter('');
  },

  unflagged: function () {
    this.filter('^unflagged');
  },

  flagged: function () {
    this.filter('^flagged');
  },

  filter: function (filter_string) {
    $('#red-flags-table').dataTable().fnFilter(filter_string, 3, true);
    $('#red-flags-table').DataTable().columns(3).search(filter_string, true).draw();
  }
};

var red_flag_sorter = {
  recent: function () {
    $('#red-flags-table').DataTable().columns(4).order("desc");
  },

  priority: function () {
    $('#red-flags-table').DataTable().order([
      [3, "asc"],
      [2, "desc"]
    ]);
  }
};

