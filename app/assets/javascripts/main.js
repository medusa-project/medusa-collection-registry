// This is a collection of one-off scripts for this application

/**
 * Bootstrap Datepicker helpers
 */
// $.extend($.fn.datepicker.defaults, {
//     parse: function (a) {
//         var b;
//         if (b = a.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)) {
//             return new Date(b[3], b[1] - 1, b[2])
//         } else {
//             return null
//         }
//     },
//     format: function (a) {
//         var b = _.string.lpad((a.getMonth() + 1).toString(), 2, '0'),
//             c = _.string.lpad(a.getDate().toString(), 2, '0');
//         return _.string.join('-', a.getFullYear(), b, c)
//     }
// });

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
