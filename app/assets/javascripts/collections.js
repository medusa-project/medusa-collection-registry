$(function () {
  $('.edit_ingest_status').on('ajax:complete', function (event, data, status, xhr) {
    $('#editIngestStatusModal').modal("hide");
    if(status == 'error') {
      alert('Unknown error updating ingest status.');
    }
  })
});

$(document).ready(function () {
  $('#collections').dataTable({
    "aaSorting" : [[0, "asc"]]
  });
})

