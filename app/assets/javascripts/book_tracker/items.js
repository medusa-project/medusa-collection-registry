$('.book-tracker-live-search').submit(function() {
    $.get(this.action, $(this).serialize(), null, 'script');
    $(this).nextAll('input').addClass('active');
    return false;
});

$(function() {
    var timer;
    $('.book-tracker-live-search input').on('keyup', function() {
        clearTimeout(timer);
        var msec = 800; // wait this long after user has stopped typing
        var val = $(this).val();
        timer = setTimeout(function() {
            $.get($('.book-tracker-live-search').attr('action'),
                $('.book-tracker-live-search').serialize(), null, 'script');
            return false;
        }, msec);
    });
});

$(document).ajaxStart(function(event, request, options) {
    $('form.book-tracker-live-search input').addClass('active');
});

$(document).ajaxComplete(function(event, request, options) {
    $('form.book-tracker-live-search input').removeClass('active');
});
