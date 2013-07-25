$(document).ready(function() {
  extract_ids(function(){

      populate_tags(function() {
          add_click_listener();
      });

      create_static_content();
  });
});

function extract_ids(callback) {
    path = window.location.pathname;
    url = "http://www.bbc.co.uk" + path;
    encoded_url = encodeURIComponent(url);
    document.ldp_ids = [];
    document.dbpedia_ids = [];
    $.getJSON("/api/tags?url=" + encoded_url, function(data) {
        $.each(data.mentions, function(index, value) {
            document.ldp_ids.push(value.uri);
            document.dbpedia_ids.push(value.dbpedia_uri);
        });
        console.log(document.ldp_ids);
        console.log(document.dbpedia_ids);
        document.data = data;
        callback();
    });
}

function populate_tags(callback) {
    $.each(document.data.mentions, function(index, value) {
      $(".story-body > p").each(function(index) {
        replace_name_with_tag(this, value, callback);
      });
      $(".article > p").each(function(index) {
        replace_name_with_tag(this, value, callback);
      });
    });
    callback();
}

function replace_name_with_tag(element, tag) {
  console.log("Replace '" + tag.guessed_name + "'");
  var re = new RegExp(tag.guessed_name, 'g');
  var html = $(element).html();
  var span = '</a><span class="ldp-tag"><span class="ldp-highlight">' +
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
    var dbpedia_uri = encodeURIComponent($(this).attr("data-dbpedia-uri"));
    var position = $(this).position();
    $("<div></div>").load("/partial/popup/loading?uri=" + uri, function() {
      $(this).attr("class", "ldp-popover-container");
      console.log(document.URL.indexOf("/sport/"));
      if(document.URL.indexOf("/sport/") !== -1) {
        /* Sport page */
        $(this).css("top", position.top + 496);
        $(this).css("left", position.left + 244);
      } else {
        /* Non-sport page */
        $(this).css("top", position.top + 153);
        $(this).css("left", position.left + 100);
      }
      $(this).hide().appendTo("body").fadeIn(200, function() {
        $(".ldp-popup-content").load("/partial/popup/detail?uri=" + uri + "&dbpedia=" + dbpedia_uri);
      });
    });
  });
}