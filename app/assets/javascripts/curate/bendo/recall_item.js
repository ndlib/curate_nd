// This script manages querying and displaying the cache status of files in
// Bendo. There are a lot of assumptions about the structure of the classes and
// elements.

// Run on jQuery's ready event as well as Turbolinks's page change event.
Blacklight.onLoad(function() {
  'use strict';

  $('.retrieval-progress-indicator').map(function() {
    var $this = $(this),
        post = $this.data('post'),
        poll = $this.data('poll'),
        redirect = $this.data('redirect'),
        message = $('.lead', $this);

    $.ajax({
      type: 'POST',
      url: post.uri,
      dataType: 'json'
    }).success( function() {
      message
        .addClass('pulse-opacity')
        .html('Loading…');
      $.poll(function(retry){
        $.getJSON(poll.uri, { item_slugs: [ poll.item_slug ] }, function(data) {
          $.each( data, function(slug, value) {
            if (value === true){
              $this.addClass('alert-success').removeClass('alert-info');
              message
                .removeClass('pulse-opacity')
                .html('Success!<br/><a href="' + redirect.uri + '" class="btn btn-default btn-lg">Manual Download</a>');
              $('.retrieval-delay-notice').remove();
              window.location.href = window.location.origin + redirect.uri;
            } else if (value === 'never') {
              $this.addClass('alert-danger').removeClass('alert-info');
              message
                .removeClass('pulse-opacity')
                .html('The file you requested is too big to process.<br/><a class="request-help btn btn-lg" href="/help_requests/new">Request Assistance</a>');
              $('.retrieval-delay-notice').remove();
            } else if (value === 'error') {
              $this.addClass('alert-danger').removeClass('alert-info');
              message
                .removeClass('pulse-opacity')
                .html('There was an error retrieving the file you requested.<br/><a class="request-help btn btn-default btn-lg" href="/help_requests/new">Request Assistance</a>');
              $('.retrieval-delay-notice').remove();
            } else {
              retry();
            }
          });
        });
      });
    }).fail( function(data) {
      var failureMessage = 'File retrieval failed: ' + data.status + ' ' + data.statusText + '<br/>' +
                           '<a class="request-help btn btn-default btn-lg" href="/help_requests/new">Request Assistance</a>';
      $this
        .addClass('alert-danger')
        .removeClass('alert-info');
      message
        .html(failureMessage);
    });
  });

  // Simple recursive polling function
  $.poll = function(wait, callback) {
    if ($.isFunction(wait)) {
      callback = wait;
      wait = 1000;
    }
    (function retry() {
      setTimeout(function(){ callback(retry); }, wait);
      wait = wait * 1.5;
    })();
  };
});
