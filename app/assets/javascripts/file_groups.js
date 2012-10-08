$(function () {
    $("#package-summary-tabs a:first").tab('show');
})

$('#package-summary-tabs a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
})
