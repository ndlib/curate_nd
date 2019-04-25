// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require array_filter_polyfill
//= require leaflet
//= require Leaflet.fullscreen/dist/Leaflet.fullscreen
//= require L.Control.Pan
//= require jquery
//= require jquery_ujs
//= require csrf_token
//
//= require blacklight/blacklight
//= require curate
//= require citation_modal
//= require jquery.sticky
//= require jquery.colorbox
//= require viewer_build

$(function(){
  'use strict';

  $('.site-feature-navigation').sticky({topSpacing:0});
  $('a[rel=popover]').popover({ html: true, trigger: 'hover' });
  $('a[rel=popover]').click(function() { return false;});
  $('.colorbox').colorbox();
  $('.colorbox-image').colorbox({
    photo: true,
    maxWidth: '90%',
    maxHeight: '90%'
  });
  $('.accordion-toggle').addClass('collapsed');

  $('#announcements').on('ajax:success', function(event){
    var $target = $(event.target),
        $announcment = $target.parent('.announcement');

    $announcment.fadeOut(100);
  });

  $('dt.attribute:contains("Date of birth:") + dd').remove();
  $('dt.attribute:contains("Date of birth:")').remove();
  $('dt.attribute:contains("Gender:") + dd').remove();
  $('dt.attribute:contains("Gender:")').remove();

  $('table.attributes').ready(function(){
    $('li.attribute.abstract').each(function(){
      var str = $(this).html(),
          regex = /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/ig,
          replaced_text = str.replace(regex, '<a href=' + $1 + ' target="_blank">' + $1 + '</a>');
      $(this).html(replaced_text);
    });
  });

  $('.control-label').on('click', '.help-toggle', function(e){
    e.preventDefault();
    $(this).next('.field-hint').slideToggle(100);
  });

  $('.field-hint')
    .hide()
    .before(
      '<a href="#" class="help-toggle">' +
      '  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" class="help-icon">' +
      '    <style type="text/css">path {fill:#001f42;}</style>' +
      '    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/>' +
      '  </svg>' +
      '</a>'
    );

    $(document).on('click', '.input-autoselect', function(){ this.select(); });
});
