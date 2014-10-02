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

$(function () {
  $("table#red-flags-table").dataTable({
    "aoColumns": [null, null, {"sType": 'priority'}, null, null, null, null],
    "aaSorting": [
      [3, "asc"],
      [2, "desc"]
    ],
    "aLengthMenu": [
      [10, 25, 50, 100, -1],
      [10, 25, 50, 100, "All"]
    ],
    "language": {
      "search": "Narrow: "
    }
  });
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
  }
}

var red_flag_sorter = {
  recent: function () {
    $('#red-flags-table').dataTable().fnSort([
      [4, "desc"]
    ]);
  },

  priority: function () {
    $('#red-flags-table').dataTable().fnSort([
      [3, "asc"],
      [2, "desc"]
    ]);
  }
}

