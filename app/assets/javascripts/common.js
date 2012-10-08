function initialize_tabs(selector) {
    $(function () {
        $(selector + " a:first").tab("show");
    });

    $(selector + ' a').click(function(e) {
        e.preventDefault();
        $(this).tab('show');
    });
}