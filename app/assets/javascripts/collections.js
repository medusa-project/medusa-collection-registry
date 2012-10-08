$(function () {
  $('.edit_ingest_status').on('ajax:complete', function (event, data, status, xhr) {
    $('#editIngestStatusModal').modal("hide");
    if(status == 'error') {
      alert('Unknown error updating ingest status.');
    }
  })
});

initialize_data_table("table#collections")
