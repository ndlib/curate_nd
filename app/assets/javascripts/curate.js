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
//= require curate/facet_mine
//= require curate/accept_contributor_agreement
//= require curate/proxy_submission
//= require curate/content_submission
//= require curate/visibility_embargo_date
//= require curate/collection_details
//= require curate/image_viewer_build
//= require handlebars
//= require curate/img_dimensions_polyfill
//= require curate/validate_doi
//= require curate/sort_and_per_page
//= require curate/grid_view_controls
//= require curate/form_input_mask
//= require orphan_file_modal
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
  $('.table.etd.contributors').manage_sections({ worktype: 'etd' });
  $('.table.dissertation.contributors').manage_sections({ worktype: 'dissertation' });
  $('form.new_document, form.edit_document').formInputMask({
    trigger: '#document_type',
    fields: {
      'Book': 'book-attribute',
      'Program': 'program-attribute'
    }
  });
  $('.link-users').linkUsers();
  $('.link-groups').linkGroups();

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


    matcher: adminMatcher,
    formatResult: format

  });


  function adminMatcher(params, data) {
    // Always return the object if there is nothing to compare
    if ($.trim(params.term) === '') {
      return data;
    }

    // Do a recursive check for options with children
    if (data.children && data.children.length > 0) {
      // Clone the data object if there are children
      // This is required as we modify the object to remove any non-matches
      var match = $.extend(true, {}, data);

      // Check each child of the option
      for (var c = data.children.length - 1; c >= 0; c--) {
        var child = data.children[c];

        var matches = adminMatcher(params, child);

        // If there wasn't a match, remove the object in the array
        if (matches == null) {
          match.children.splice(c, 1);
        }
      }

      // If any children matched, return the new object
      if (match.children.length > 0) {
        return match;
      }

      // If there were no matching children, check just the plain object
      return adminMatcher(params, match);
    }

    var original = data.text.toUpperCase();
    var term = params.term.toUpperCase();

    // Check if the text contains the term
    if (original.indexOf(term) > -1) {
      return data;
    }

    if (data.id && data.id.toUpperCase().indexOf(term) > -1) {
      return data;
    }

    // If it doesn't contain the term, don't return anything
    return null;
  }





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
