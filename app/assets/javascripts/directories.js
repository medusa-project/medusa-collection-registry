initialize_data_table("table#files", {
  'order' : [[1, 'asc']]
});
initialize_data_table("table#subdirectories", {});

$(document).ready(function () {
    replace_delayed_thumbnail_spans();
    $('#files').on('draw.dt', replace_delayed_thumbnail_spans);
  }
);

function replace_delayed_thumbnail_spans() {
  $('span.delayed-thumbnail:visible').each(function(i, element) {
    var path = $(element).attr('data-thumb-path');
    var alt = $(element).attr('data-thumb-alt');
    var img = $("<img></img>");
    img.attr('src', path);
    img.attr('alt', alt);
    $(element).replaceWith(img);
  })
}
