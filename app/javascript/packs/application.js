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
//TODO: Importing css for jquery-ui seems to interact badly with some other stuff - don't know why yet.
// Also possible that
//we need a specific version of jquery-ui to go with jquery2 that we're using now.
//An example of the problem is the add event dialog off a file group - with the jquery-ui stuff
//imported it does not behave properly.
//Maybe try only importing the css that we actually use
//import('jquery-ui/themes/base/all');
//Also, I think we only use jquery-ui for datepicker and possibly some effects - maybe find
//other sources for the same
require('jquery-ujs');
//I have checkboxes.js locked at this version in yarn.lock - it doesn't seem to load nicely
//unless I go specifically to the exact file.
require('checkboxes.js/dist/jquery.checkboxes-1.2.2.min');

require("expose-loader?_!underscore");
require("expose-loader?_.string!underscore.string");

require('bootstrap-datepicker');
require('bootstrap-datepicker/dist/css/bootstrap-datepicker3.min.css');

import Chartkick from 'chartkick';

window.Chartkick = Chartkick;
import Chart from 'chart.js';

Chartkick.addAdapter(Chart);

require('expose-loader?ClipboardJS!clipboard');

import Localtime from 'local-time';

Localtime.start();

require('../rich_editor/rich_editor');