var active_tabs = active_tabs || [];
$(function () {
    $(active_tabs).each(function (i, val) {
        $("[href='" + val + "']").click();
    });
});
