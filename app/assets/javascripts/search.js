function indicate_search_results_in_tab_header(record_count, tab_id) {
    var icon = $('i', $("a[href='" + tab_id + "']"));
    var new_icon = (record_count > 0) ? 'fa-check' : 'fa-times';
    var new_color = (record_count > 0) ? 'search-hit' : 'search-missed';
    icon.attr('class', _.string.join(' ', 'fa', new_icon, new_color));
}
