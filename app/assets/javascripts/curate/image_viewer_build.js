Blacklight.onLoad(function() {
  'use strict';

  $('.image-viewer-integration').each(function() {
    var $this = $(this);
    var manifest_url = $this.data("manifest-url");
    $.ajax({
      url: manifest_url,
      type: "GET"
    }).success(function(response) {
      var $work_representation = $this.find(".work-representation");
      var thumbnail_url = response.thumbnail[0].id;
      if(thumbnail_url) {

        var $expand_link = $("<img src='" + thumbnail_url + "' /><p><a href='https://viewer-iiif.library.nd.edu/universalviewer/index.html#?manifest=" + manifest_url+ "'>Expand</a></p>");
        $work_representation.html($expand_link);
      }
      $this.find(".spinner").hide();
      $work_representation.fadeIn();
    }).fail(function(response) {
      // Fallback to the CurateND base response
      $this.find(".spinner").hide();
      $this.find(".work-representation").fadeIn();
    });
  });
})
