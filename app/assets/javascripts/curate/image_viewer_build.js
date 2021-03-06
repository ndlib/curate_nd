Blacklight.onLoad(function() {
  'use strict';

  $('.image-viewer-integration').each(function() {
    var $this = $(this);
    var manifest_viewer = $this.data("manifest-viewer");
    var manifest_url = $this.data("manifest-url");
    $.ajax({
      url: manifest_url,
      type: "GET"
    }).success(function(response) {
      var $work_representation = $this.find(".iiif-work-representation");
      var thumbnail_url = response.thumbnail[0].id;
      if(thumbnail_url) {

        var $expand_link = $("<a target='_blank' href='" + manifest_viewer + manifest_url + "'><img src='" + thumbnail_url + "' /><p>Click to Expand</a></p>");
        $work_representation.html($expand_link);
      }

      $this.find(".spinner").hide();
      $work_representation.fadeIn();
    }).fail(function(response) {
      // Fallback to the CurateND base response
      $this.find(".spinner").hide();
      $this.find(".iiif-work-representation").fadeIn();
    });
  });
})
