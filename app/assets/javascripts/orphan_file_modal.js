$(function(){
  'use strict';

  var $window = $(window),
      $modal = $('#ajax-modal'),
      resolution = screen.width + 'x' + screen.height,
      viewport = $window.width() + 'x' + $window.height(),
      current_url = document.location.href;

  $(document).on('click','.request-file-removal', function(event){
    event.preventDefault();
    var target = $(this).attr('href');

    $('body').modalmanager('loading');
    setTimeout(function(){
      $modal.load(target + ' #new_orphan_file_request', function(){
        $('body').modalmanager('loading');
        $modal.modal();
      });
    }, 1000);
  });
});
