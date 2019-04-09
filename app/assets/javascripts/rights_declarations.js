function update_rights_form() {
  var custom_copyright_statement_input = $(".custom_rights_disableable");
  if ($(".update_rights_form").val() == "cus") {
    custom_copyright_statement_input.removeAttr("disabled");
  } else {
    custom_copyright_statement_input.attr("disabled", true).val('');
  }
}
$(function () {
  update_rights_form();
  $(".update_rights_form").change(update_rights_form);
});