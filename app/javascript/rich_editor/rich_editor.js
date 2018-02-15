require('tinymce/themes/modern');
import tinymce from 'tinymce';
require('tinymce/skins/lightgray/content.min.css');
require('tinymce/skins/lightgray/skin.min.css');

tinymce.init({
      selector: 'textarea.rich-editor',
      //necessary skin files are included above
      skin: false
    }
)
