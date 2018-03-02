$(document).ready(function () {
  initialize_data_table_synchronous("table#file_formats", {
      'buttons': [],
  });
})

$(document).ready(function () {
  $('.logical-extension').on('click', function(e) {
    update_logical_extensions(this.innerText);
  })
})

function update_logical_extensions(text) {
  var input = logical_extensions_string_input();
  if (_.string.isBlank(input.val())) {
    input.val(text);
  } else {
    input.val(input.val() + ', ' + text);
  }
}

function logical_extensions_string_input() {
  return $('#file_format_logical_extensions_string');
}