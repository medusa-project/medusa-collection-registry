var active_tabs;
$(function () {
  if (!_.isUndefined(active_tabs)) {
    $(active_tabs).each(function (i, val) {
      $("[href='" + val + "']").click();
    });
  }
});
