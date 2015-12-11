initialize_data_table("table#projects", {});
initialize_data_table("table#items", {});

$(function () {
  restore_item_table_size();
  watch_item_barcode(".barcode_input");
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
  $(barcode_field_selector).keypress(function(event) {
    if (event.keyCode == 13 && prevent_enter_in_barcode_field) {
      event.preventDefault();
    }
  });
}

function query_barcode(value) {
  if (possible_barcode(value)) {
    $.get('/items/barcode_lookup.json', {"barcode": value}, function (jsonResult) {
      barcode_item_data = jsonResult;
      populate_barcode_items();
      if (barcode_item_data.length == 1) {
        insert_barcode_item(0);
      }
      prevent_enter_in_barcode_field = false;
    })
  }
}

function possible_barcode(s) {
  if (s) {
    return s.length >= 14;
  } else {
    return false;
  }
}

function populate_barcode_items() {
  $('#barcode_items').html('');
  for (i = 0; i < barcode_item_data.length; i++) {
    if (i != 0) {
      $('#barcode_items').append('<hr/>')
    }
    $('#barcode_items').append(barcode_item_html(i));
  }
}

function barcode_item_html(i) {
  var item_data = barcode_item_data[i];
  var item_div = $('<div></div>');
  var item_link = $('<a href="#" class="btn btn-xs btn-default">Use</a>');
  item_link.click(function () {
    insert_barcode_item(i);
    return false;
  });
  var item_text = $('<span>&nbsp;' + item_data['bib_id'] + ': ' + item_data['title'] + '<span>');
  item_div.append(item_link);
  item_div.append(item_text);
  return item_div;
}

function insert_barcode_item(i) {
  var item_data = barcode_item_data[i];
  Object.keys(item_data).forEach(function (key) {
    var field = "#item_" + key;
    if (is_blank($(field).val())) {
      $(field).val(item_data[key]);
    }
  });
}

function is_blank(string) {
  return /^\s*$/.test(string);
}

function before_assign_batch_submit () {
  localStorage.setItem(item_table_storage_name(), JSON.stringify($('#items').DataTable().page.len()));
  set_item_table_page_length(-1);
}

function restore_item_table_size () {
  var length = JSON.parse(localStorage.getItem(item_table_storage_name()));
  if (length) {
    set_item_table_page_length(length);
  }
}

function set_item_table_page_length (length) {
  $('#items').DataTable().page.len(length).draw();
}

function item_table_storage_name () {
  return 'DataTables_item_table_' + window.location.pathname;
}
