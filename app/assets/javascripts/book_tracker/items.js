$(function() {
    // prevent searching both "in" and "not in" a particular service
    // simultaneously
    var checkboxes = $('.book-tracker-service-checkbox');
    checkboxes.on('change', function() {
        var changed = $(this);
        var service = changed.val();
        var match = changed.attr('name');
        checkboxes.each(function() {
            if ($(this).val() == service && $(this).attr('name') != match) {
                if (changed.prop('checked')) {
                    $(this).prop('checked', false);
                }
            }
        });
        refreshCheckAllButtons();
    });

    function refreshCheckAllButtons() {
        $('.book-tracker-service-checkbox').parents('table:first').find('tr').each(function() {
            var row_checkboxes = $(this).find('.book-tracker-service-checkbox');
            var row_checked_boxes = row_checkboxes.filter(':checked');
            if (row_checkboxes.length == row_checked_boxes.length) {
                $(this).find('.mbt-check-all').attr('disabled', true);
                $(this).find('.mbt-uncheck-all').attr('disabled', false);
            } else if (row_checked_boxes.length == 0) {
                $(this).find('.mbt-check-all').attr('disabled', false);
                $(this).find('.mbt-uncheck-all').attr('disabled', true);
            } else {
                $(this).find('.mbt-check-all').attr('disabled', false);
                $(this).find('.mbt-uncheck-all').attr('disabled', false);
            }
        });
    }

    var check_all_buttons = $('.mbt-check-all');
    check_all_buttons.on('click', function() {
        var same_row_checkboxes = $(this).parents('tr:first').
            find('input[type="checkbox"]');
        same_row_checkboxes.
            prop('checked', !$(this).hasClass('mbt-uncheck-all')).
            trigger('change');
        refreshCheckAllButtons();
        return false;
    });

    $('.mbt-clear').on('click', function() {
        var form = $('.book-tracker-search');
        form.find('input[type=checkbox]').prop('checked', false).trigger('change');
        form.find('textarea, input[type=text], input[type=search]').val(null);
        form.submit();
    });

    // set up infinite scrolling
    var loading = false;
    var results_container = $('#items_list');
    var num_results = parseInt($('input[name="num_results"]:last').val());

    $(window).scroll(function() {
        if ($(window).scrollTop() + $(window).height() > results_container.height() - 2000 &&
            results_container.find('tr').length < num_results) {
            var next_page_url = $('input[name="next-page-url"]:last').val();
            if (next_page_url) {
                if (loading) {
                    return;
                }
                loading = true;
                console.log('Loading ' + next_page_url);
                $.ajax({
                    url: next_page_url,
                    type: 'POST',
                    success: function(html) {
                        results_container.find('tbody:first').append(html);
                        loading = false;
                    }
                });
            }
        }
    });
});
