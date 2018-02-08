// This is a collection of one-off scripts for this application

/**
 * Bootstrap Datepicker helpers
 */
$.extend($.fn.datepicker.defaults, {
    parse: function (a) {
        var b;
        if (b = a.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)) {
            return new Date(b[3], b[1] - 1, b[2])
        } else {
            return null
        }
    },
    format: 'yyyy-mm-dd'
});

/**
 * Toggle collapse the sidebar
 */
$('a.toggles').click(function () {
    $('a.toggles i').toggleClass('icon-arrow-left icon-arrow-right');

    $('#sidebar').animate({
        width: 'toggle'
    }, 0);
    $('#content').toggleClass('span12 span9 no-sidebar');
});

/**
 * Tooltip placement for the toggle button
 */
$('a[rel=tooltip]').tooltip({
    placement: 'right'
});
