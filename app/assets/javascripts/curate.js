// This is a manifest file that'll be compiled into curate.js, which will include all the files
// listed below.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//
//= require jquery-ui-1.9.2/jquery.ui.widget
//= require jquery-ui-1.9.2/jquery.ui.core
//= require jquery-ui-1.9.2/jquery.ui.menu
//= require jquery-ui-1.9.2/jquery.ui.position
//= require jquery-ui-1.9.2/jquery.ui.autocomplete
//
//= require blacklight/blacklight
//
//= require bootstrap-dropdown
//= require bootstrap-button
//= require bootstrap-collapse
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-datepicker/core
//= require select2
//
//= require manage_repeating_sections
//= require manage_repeating_fields
//= require toggle_details
//= require help_modal
//= require jquery.tokeninput
//= require readmore.min
//= require curate/select_works
//= require curate/link_users
//= require curate/link_groups
//= require curate/proxy_rights
//= require curate/facet_mine
//= require curate/accept_contributor_agreement
//= require curate/proxy_submission
//= require curate/content_submission
//= require curate/visibility_embargo_date
//= require curate/collection_details
//= require curate/viewer_build
//= require handlebars
//= require curate/img_dimensions_polyfill
//= require curate/validate_doi
//= require curate/sort_and_per_page
//= require curate/grid_view_controls
//= require curate/form_input_mask
//
//= require curate/bendo/cache_status
//= require curate/bendo/recall_item


// Initialize plugins and Bootstrap dropdowns on jQuery's ready event as well as
// Turbolinks's page change event.
Blacklight.onLoad(function() {
  'use strict';

  $('abbr').tooltip();

  $('body').on('keypress', '.multi-text-field', function(event) {
    var $activeField = $(event.target).parents('.field-wrapper'),
        $activeFieldControls = $activeField.children('.field-controls'),
        $addControl=$activeFieldControls.children('.add'),
        $removeControl=$activeFieldControls.children('.remove');
    if (event.keyCode === 13) {
      event.preventDefault();
      $addControl.click();
      $removeControl.click();
    }
  });
  $('.multi_value.control-group').manage_fields();
  $('.table.contributors').manage_sections();
  $('form.new_document, form.edit_document').formInputMask({
    trigger: '#document_type',
    fields: {
      'Book': 'book-attribute',
      'Program': 'program-attribute'
    }
  });
  $('.link-users').linkUsers();
  $('.link-groups').linkGroups();
  $('.proxy-rights').proxyRights();

  // Based on example provided by Greg Kempe (@longhotsummer)
  // https://gist.github.com/longhotsummer/ba9c96bb2abb304e4095ce00df17ae2f
  $('#image-viewer-content').on('load', function() {
    var map = L.map('image-viewer', {
      fullscreenControl: true,
      minZoom: 1,
      maxZoom: 4,
      center: [0, 0],
      zoom: 1,
      crs: L.CRS.Simple
    });

    var $content = $(this),
        w = $content.naturalWidth(),
        h = $content.naturalHeight(),
        url = $content.attr('src'),
        southWest = map.unproject([0, h], map.getMaxZoom()-1),
        northEast = map.unproject([w, 0], map.getMaxZoom()-1),
        bounds = new L.LatLngBounds(southWest, northEast);

    L.imageOverlay(url, bounds).addTo(map);
    map.setMaxBounds(bounds);
    L.control.pan().addTo(map);
  });

  $('#set-access-controls .datepicker').datepicker({
    format: 'yyyy-mm-dd',
    startDate: '+1d'
  });

  $('.remove-member').on('ajax:success', function(){
    window.location.href = window.location.href;
  });

  $('[data-toggle="dropdown"]').dropdown();

  $('.generic_file_actions').on('click', '.disabled', function(event) {
    event.preventDefault();
  });

  $('input.datepicker').datepicker({
    format: 'yyyy-mm-dd'
  });

  $('li.disabled').on('click', 'a', function(event) {
    event.preventDefault();
  });

  $('.department-select').select2({
    placeholder: 'Please select one or more; type to search',
    formatResultCssClass:function(object) {
      if(object.disabled === true){
        return 'bold-row';
      }
    },
    formatResult: format

  });

  function format(option) {
    var originalOption = option.element,
    noOfSpaces = $(originalOption).data('indent');

    if (noOfSpaces === undefined ) {
      return option.text;
    } else {
      var space = '&nbsp',
        returnValue = '';
      for(var index=0; index < noOfSpaces*3; index++) {
        returnValue += space;
      }
      return  returnValue + option.text;
    }
  }
});
