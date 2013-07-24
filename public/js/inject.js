$(document).ready(function() {
  path = window.location.pathname;
  url = "http://www.bbc.co.uk" + path
  encoded_url = encodeURIComponent(url)
  $.getJSON("/api/tags?url=" + encoded_url, function(data) {
    console.log(data.about);
    console.log(data.mentions);
    
    $.each(data.mentions, function(index, value) {
      var re = new RegExp(value.guessed_name, 'g');
      $(".story-body p").each(function( index ) {
        var html = $(this).html();
        var span = '<span class="ldp-highlight" ' +
          'data-dbpedia-uri="' + value.dbpedia_uri + '"' +
          'data-uri="' + value.uri + '">' +
          value.guessed_name + '</span>';
        var new_html = html.replace(re, span);
        $(this).html(new_html);
      });
    });
  });
});