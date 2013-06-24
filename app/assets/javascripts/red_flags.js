$(function () {
  $("table#red-flags-table").dataTable({
    "aaSorting":[[4, "desc"]]
  });
});

var red_flag_filter = {
  all: function() {
    this.filter('');
  },

  unflagged: function() {
    this.filter('^unflagged');
  },

  flagged: function () {
    this.filter('^flagged');
  },

  filter: function(filter_string) {
    $('#red-flags-table').dataTable().fnFilter(filter_string, 3, true);
  }
}

