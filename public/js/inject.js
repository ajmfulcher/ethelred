$(document).ready(function() {
  populate_tags(function() {
    add_click_listener();
  });
});

function populate_tags(callback) {
  path = window.location.pathname;
  url = "http://www.bbc.co.uk" + path
  encoded_url = encodeURIComponent(url)
  $.getJSON("/api/tags?url=" + encoded_url, function(data) {
    $.each(data.mentions, function(index, value) {
      $(".story-body > p").each(function(index) {
        replace_name_with_tag(this, value, callback);
      });
    });
    callback();
  });
}

function replace_name_with_tag(element, tag) {
  var re = new RegExp(tag.guessed_name, 'g');
  var html = $(element).html();
  var span = '<span class="ldp-tag"><span class="ldp-highlight">' +
    tag.guessed_name + '</span><span data-uri="' + tag.uri + '" data-dbpedia-uri="' + tag.dbpedia_uri + '" class="ldp-person-icon"></span></span>';
  var new_html = html.replace(re, span);
  $(element).html(new_html);
}

function hide_other_popovers() {
  $(".ldp-popover").each(function() {
    $(this).fadeOut(200, function() {
      $(this).remove();
    });
  });
}

function add_click_listener() {
  $(".ldp-person-icon").click(function() {
    hide_other_popovers();
    var uri = encodeURIComponent($(this).attr("data-uri"));
    var position = $(this).position();
    $("<div></div>").load("/partial/popup/loading?uri=" + uri, function() {
      $(this).attr("class", "ldp-popover-container");
      $(this).css("top", position.top + 153);
      $(this).css("left", position.left + 63);
      $(this).hide().appendTo("body").fadeIn(200, function() {
        
      });
    });
  });
}