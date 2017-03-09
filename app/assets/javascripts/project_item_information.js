//This is based off of the ellipsis.js plugin for datatables
//Instead of truncating at a certain point we want to separate on a
//conventionally defined string then display one part and use the rest as the title for mouseovers.
jQuery.fn.dataTable.render.item_information= function () {
  var separator = "|$^";
  var esc = function ( t ) {
    return t
      .replace( /&/g, '&amp;' )
      .replace( /</g, '&lt;' )
      .replace( />/g, '&gt;' )
      .replace( /"/g, '&quot;' );
  };
  return function (d, type, row) {
    if ( type !== 'display' ) {
      return d;
    }

    if ( typeof d !== 'number' && typeof d !== 'string' ) {
      return d;
    }
    var coercedString = d.toString();
    var strings = coercedString.split(separator, 2);
    var shortString = strings[0];
    var fullString = esc(strings[1]);

    return '<span class="ellipsis" title="'+ fullString + '">' + shortString + '</span>';
  }
}