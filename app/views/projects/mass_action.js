$('#item_mass_edit_modal').modal('hide');
reset_item_mass_edit_form ();
$('#items').DataTable().ajax.reload();