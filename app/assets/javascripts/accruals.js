function toggle_accrual_directories () {
  toggle_checkboxes_with_class('accrual_directory');
};

function toggle_accrual_files () {
  toggle_checkboxes_with_class('accrual_file');
};

function toggle_checkboxes_with_class (c) {
  var all_matching_checkboxes = $("input:checkbox." + c);
  var checked_matching_checkboxes = $("input:checkbox:checked." + c);
  all_matching_checkboxes.prop('checked', checked_matching_checkboxes.length == 0);
};