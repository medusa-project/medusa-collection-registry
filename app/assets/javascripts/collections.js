$(function () {
  //Create new checkbox with the right id, value, and label text
  $('#new_object_type').on('ajax:success', function (event, data, status, xhr) {
    var id = data.id;
    var new_checkbox = $('#collection_object_types label.checkbox').first().clone();
    var input = $('input', new_checkbox);
    input.first().val(id);
    input.first().attr('id', 'collection_object_type_ids_' + id);
    input.attr('checked', 'checked');
    //I can't figure a way to simply set the text in the cloned element without clobbering the input, so I do this
    new_checkbox.text(data.name);
    new_checkbox.prepend(input);
    $('#collection_object_types div.controls label').last().after(new_checkbox);
  });
  $('#new_object_type').on('ajax:complete', function (event, data, status, xhr) {
    $('#newObjectTypeModal').modal("hide");
    if (status == 'error') {
      alert('Error creating new object type. May be blank or duplicate.');
    }
  });

  $('.edit_ingest_status').on('ajax:complete', function (event, data, status, xhr) {
    $('#editIngestStatusModal').modal("hide");
    if(status == 'error') {
      alert('Unknown error updating ingest status.');
    }
  })
});

