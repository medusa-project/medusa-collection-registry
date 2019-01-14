function update_file_format_reasons() {
  var checkboxes = $("input.check_boxes");
  if ($("#file_format_test_pass_true").is(":checked")) {
    checkboxes.prop("checked", false).attr("disabled", true);
  } else {
    checkboxes.removeAttr("disabled");
  }
};

function add_reason(id, label) {
  var last_checkbox = $('span.checkbox:last');
  var new_checkbox = last_checkbox.clone();
  var new_label = $('label', new_checkbox);
  var new_input = $('input', new_checkbox);
  new_label.attr('for', new_label.attr('for').replace(/\d+$/, id));
  new_input.val(id).attr('checked', 'checked');
  new_input.attr('id', new_input.attr('id').replace(/\d+$/, id));
  new_input.detach();
  new_label.text(label);
  new_label.prepend(new_input);
  last_checkbox.after(new_checkbox);
  update_file_format_reasons();
}

$(function () {
  update_file_format_reasons();
  $("input.radio_buttons").change(update_file_format_reasons);
  initialize_data_table("table#file_format_tests", {});
});