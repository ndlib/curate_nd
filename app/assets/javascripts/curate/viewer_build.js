$(function(url){
  'use strict';

  var request = false;
  if(window.XMLHttpRequest)
    request = new XMLHttpRequest();
  else
    request = new ActiveXObject("Microsoft.XMLHTTP");
  }
  request.open('GET', url);
  if (request.status === 200) { return true; }
  return false;
})
