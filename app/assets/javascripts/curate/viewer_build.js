// Javascript, using JQuery library
// Look for dom element with class "image-viewer-integration"
// On that DOM element, is a data-manifest-url attribute, this is the URL to check
// Now check the data-manifest-url (via an HTTP HEAD request) to see if it has a 2xx status
// If 2xx status, we replace the inner HTML of the dom element ".work-representation" (scoped to above image-viewer-integration DOM element)
//  <iframe src='https://universalviewer.io/uv.html?manifest=<%= manifest_url %>'></iframe>
// Once replaced, we then toggle the ".work-representation" dom element's to now be visible (regardless of whether we replaced the inner HTML or not, because the CSS will default the ".image-viewer-integration .work-representation" to not visible
// Then hide the spinner



// the code below causes the app to crash.
// Error: ActionView::Template::Error - Unexpected token name «request», expected punc «,». To use ES6 syntax, harmony mode must be enabled with Uglifier.new(:harmony => true).

// $(function(url){
//   'use strict';

  // var request = false;
  // if(window.XMLHttpRequest)
  //   request = new XMLHttpRequest();
  // else
  //   request = new ActiveXObject("Microsoft.XMLHTTP");
  // }
  // request.open('GET', url);
  // if (request.status === 200) { return true; }
//   return false;
// })
