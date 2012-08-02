// This is a collection of one-off scripts for this application

/**
 * Bootstrap Datepicker helpers
 */
$.extend($.fn.datepicker.defaults, {
	parse: function(a) {
		var b;
		if (b = a.match(/^(\d{2,2})\/(\d{2,2})\/(\d{4,4})$/)) {
			return new Date(b[3], b[1] - 1, b[2])
		} else {
			return null
		}
	},
	format: function(a) {
		var b = (a.getMonth() + 1).toString(),
			c = a.getDate().toString();
		if (b.length === 1) {
			b = "0" + b
		}
		if (c.length === 1) {
			c = "0" + c
		}
		return b + "/" + c + "/" + a.getFullYear()
	}
})

/**
 * Toggle collapse the sidebar
 */
$('a.toggles').click(function() {
    $('a.toggles i').toggleClass('icon-arrow-left icon-arrow-right');

    $('#sidebar').animate({
        width: 'toggle'
    }, 0);
    $('#content').toggleClass('span12 span9');
    $('#content').toggleClass('no-sidebar');
})

/**
 * Tooltip placement for the toggle button
 */
$('a[rel=tooltip]').tooltip({
  placement : 'right'
});