initialize_data_table("table#projects", {});
initialize_data_table("table#items", {});

//JS to watch barcode field and call back to rails for barcode information when appropriate
//Hook up when displaying new item form
var barcode_item_data = null;

function watch_item_barcode(barcode_field_selector) {
  $(barcode_field_selector).on("input", function() {
     query_barcode($(barcode_field_selector).val())
    }
  );
}

function query_barcode(value) {
  if (possible_barcode(value)) {
    $.get('/items/barcode_lookup.json', {"barcode" : value}, function (jsonResult) {
      barcode_item_data = jsonResult;
    })
  }
}

function possible_barcode(s) {
  return s.length == 14;
}