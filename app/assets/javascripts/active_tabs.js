$(function () {
  if (typeof active_tabs != "undefined") {
    $(active_tabs).each(function (i, val) {
      $("[href='" + val + "']").click();
    });
  }
});
