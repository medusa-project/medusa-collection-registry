initialize_data_table("table#projects", {});

$(function () {
    watch_item_barcode(".barcode_input");
    set_up_bibid_clipboard();
});

//JS to watch barcode field and call back to rails for barcode information when appropriate
//Hook up when displaying new item form
var barcode_item_data = [];
var prevent_enter_in_barcode_field = true;

function watch_item_barcode(barcode_field_selector) {
    query_barcode($(barcode_field_selector).val());
    $(barcode_field_selector).on("input", function () {
            query_barcode($(barcode_field_selector).val());
        }
    );
    $(barcode_field_selector).keypress(function (event) {
        if (event.keyCode === 13 && prevent_enter_in_barcode_field) {
            event.preventDefault();
        }
    });
}

function query_barcode(value) {
    if (possible_barcode(value)) {
        $.getJSON( '/items.json', {"barcode": value}, function (jsonResult) {
            let item_data = jsonResult;
            if ((item_data.length != undefined) && (item_data.length > 0)) {
                show_duplicate_error(item_data);
            } else {
                lookup_barcode(value);
            }
        })
    } else {
        clear_barcode_items();
    }
}

function lookup_barcode(value){
    $.get('/items/barcode_lookup.json', {"barcode": value}, function (jsonResult) {
        barcode_item_data = jsonResult;
        populate_barcode_items();
        if (barcode_item_data.length === 1) {
            insert_barcode_item(0);
        } else if (barcode_item_data.length === 0) {
            show_barcode_error();
        }
        prevent_enter_in_barcode_field = false;
    })
}

function possible_barcode(s) {
    return _.isString(s) && s.length >= 14;
}

function clear_barcode_items() {
    $('#barcode_items').html('');
}

function populate_barcode_items() {
    clear_barcode_items();
    for (i = 0; i < barcode_item_data.length; i++) {
        if (i !== 0) {
            $('#barcode_items').append('<hr/>')
        }
        $('#barcode_items').append(barcode_item_html(i));
    }
}

function show_duplicate_error(itemdata) {
    let warning = 'Warning! The barcode you are attempting to retrieve is '
    warning = warning + 'already associated with an item:'
    $('#barcode_items').append('<span class="bg-danger">' + warning + '</span>')
    $.each(itemdata, function(i, item) {
        $('#barcode_items').append('<a href="/items/' + item.id + '">'+ item.title +'</a>')
    });


}

function show_barcode_error() {
    clear_barcode_items();
    $('#barcode_items').append('<span class="bg-danger">Warning! The barcode you are attempting to retrieve is not available in the library catalog.</span>')
}

function barcode_item_html(i) {
    let item_data = barcode_item_data[i];
    let item_div = $('<div></div>');
    let item_link = $('<a href="#" class="btn btn-xs btn-default">Use</a>');
    item_link.click(function () {
        insert_barcode_item(i);
        return false;
    });
    let item_text = $('<span>&nbsp;' + item_data['bib_id'] + ': ' + item_data['title'] + '<span>');
    item_div.append(item_link);
    item_div.append(item_text);
    return item_div;
}

function insert_barcode_item(i) {
    var item_data = barcode_item_data[i];
    Object.keys(item_data).forEach(function (key) {
        var field = "#item_" + key;
        if (_.string.isBlank($(field).val())) {
            $(field).val(item_data[key]);
        }
    });
}

function before_mass_action_submit() {
    localStorage.setItem(item_table_storage_name(), JSON.stringify($('#items').DataTable().page.len()));
    set_item_table_page_length(-1);
}

function set_item_table_page_length(length) {
    $('#items').DataTable().page.len(length).draw();
}

function item_table_storage_name() {
    return 'DataTables_item_table_' + window.location.pathname;
}

function set_up_bibid_clipboard() {
    new ClipboardJS('#bibids-to-clipboard-btn', {
        text: function () {
            return selected_bibids();
        }
    })
}

function selected_bibids() {
    var rows = checked_rows('#items');
    var bib_id_column = column_with_header('#items', 'Bib Id');
    var bibids = _.reject(_.map(rows, function (row) {
        return row[bib_id_column];
    }), _.string.isBlank);
    //var checked = $('#items input:checked');
    //var bibids = _.reject($.map(checked, checkbox_to_bibid), _.string.isBlank);
    if (_.isEmpty(bibids)) {
        bibids = [' '];
    }
    return _.reduce(bibids, function (memo, obj) {
        return _.string.join(',', memo, obj)
    });
}

function checked_rows(table_selector) {
    var rows = $(table_selector).DataTable().rows().data();
    var checkbox_column = column_with_header(table_selector, 'Mass Action');
    return _.filter(rows, function (row) {
        var checkbox_id = $(row[checkbox_column]).attr('id');
        return $('#' + checkbox_id).prop('checked');
    });
}

function column_with_header(table_selector, header_text) {
    var columns = $(table_selector).DataTable().columns();
    var headers = columns.header();
    var header = _.find(headers, function (header) {
        return $(header).text() === header_text;
    });
    return $(header).attr('data-column-index');
}

function show_item_mass_edit() {
    $('#mass_action_item_ids').val(_.string.join(',', $.map($('.mass-item-checkbox:checked'), function (e) {
        return $(e).val();
    })));
    $('#item_mass_edit_modal').modal('show');
}

function reset_item_mass_edit_form() {
    var form = $('#item_mass_edit_modal form');
    $('input[type="text"]', form).val('');
    $('input[type="checkbox"]', form).prop('checked', false);
    $('select', form).val('');
    $('input.radio_buttons[value^="Don"]').prop('checked', true);
}