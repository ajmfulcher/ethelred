$(document).ready(function() {
  path = window.location.pathname;
  url = "http://www.bbc.co.uk" + path
  encoded_url = encodeURIComponent(url)
  $.getJSON("/api/tags?url=" + encoded_url, function(data) {
    console.log(data.about);
    console.log(data.mentions);
  });
});