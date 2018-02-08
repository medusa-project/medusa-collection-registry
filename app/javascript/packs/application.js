/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('expose-loader?$!jquery');
require('expose-loader?jQuery!jquery');
require('jquery-ui');
//TODO: This seems to interact badly with some other stuff - don't know why yet. Also possible tht
//we need a specific version of jquery-ui to go with jquery2 that we're using now.
//Maybe try only importing the css that we actually use
//import('jquery-ui/themes/base/all');
require('jquery-ujs');
require('checkboxes.js/src/jquery.checkboxes');

require("expose-loader?_!underscore");
require("expose-loader?_.string!underscore.string");

require('bootstrap-datepicker-webpack');
import('bootstrap-datepicker-webpack/dist/css/bootstrap-datepicker3');

require('chart.js');
require('expose-loader?Chartkick!chartkick');

require('expose-loader?Clipboard!clipboard');

import Localtime from 'local-time';
Localtime.start();
