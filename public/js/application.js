// Generated by CoffeeScript 1.3.3
(function() {
  var app;

  app = {
    initialize: function() {
      app.consoleHack();
      app.setupStars();
      app.setupBucketForm();
      app.setupManifest();
      app.setupPusher();
      return app.addCommas();
    },
    consoleHack: function() {
      if (typeof console === "undefined") {
        return window.console = {
          log: function() {}
        };
      }
    },
    setupStars: function() {
      console.log("setting up STARS !!!!!!");
      return $(".star").live('click', function(e) {
        e.preventDefault();
        return app.notifyStar(this);
      });
    },
    notifyStar: function(star) {
      var _this = this;
      return $.ajax({
        type: "POST",
        url: "/stars.json",
        dataType: "json",
        contentType: "application/json",
        data: JSON.stringify({
          "tweet_id": $(star).parents('.tweet').attr('id')
        }),
        success: function(data, textStatus) {
          return $(star).parents('.tweet').addClass("starred");
        }
      });
    },
    setupBucketForm: function() {
      return $('#new_bucket_form').ajaxForm(function(data, textStatus) {
        $(':input', '#new_bucket_form').not(':button, :submit, :reset, :hidden').val('');
        return $('.mf_list li').remove();
      });
    },
    format: function(countElement) {
      var element;
      element = $(countElement);
      return element.html(app.commaFormat(element.html()));
    },
    commaFormat: function(nStr) {
      var rgx, x, x1, x2;
      console.log("formatting count for ", nStr);
      nStr += "";
      x = nStr.split(".");
      x1 = x[0];
      x2 = (x.length > 1 ? "." + x[1] : "");
      rgx = /(\d+)(\d{3})/;
      while (rgx.test(x1)) {
        x1 = x1.replace(rgx, "$1" + "," + "$2");
      }
      return x1 + x2;
    },
    addCommas: function() {
      var count, _i, _len, _ref, _results;
      _ref = $(".bucket_count");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        count = _ref[_i];
        _results.push(app.format(count));
      }
      return _results;
    },
    setupManifest: function() {
      return $('#bucket_words').manifest();
    },
    setupPusher: function() {
      var apiKey, bucketsChannel, pusher, result, tweetsChannel;
      apiKey = $('#pusher_api').html();
      pusher = new Pusher(apiKey);
      result = "";
      result += "options: " + pusher['options'] + "\n";
      result += "path: " + pusher['path'] + "\n";
      result += "key: " + pusher['key'] + "\n";
      result += "channels: " + pusher['channels'] + "\n";
      result += "global_channel: " + pusher['global_channel'] + "\n";
      result += "secure: " + pusher['secure'] + "\n";
      result += "connected: " + pusher['connected'] + "\n";
      result += "retry_counter: " + pusher['retry_counter'] + "\n";
      result += "encrypted: " + pusher['encrypted'] + "\n";
      result += "connection " + pusher.connection;
      tweetsChannel = pusher.subscribe("tweets");
      bucketsChannel = pusher.subscribe("buckets");
      tweetsChannel.bind("tweet", function(tweet) {
        var linkifiedText, template;
        linkifiedText = $("<p>" + tweet.text + "</p>").linkify().html();
        template = $("#tweet-template").html().replace("{{TWEET_ID_STR}}", tweet.id_str).replace("{{PROFILE_IMAGE}}", tweet.user.profile_image_url).replace("{{TEXT}}", linkifiedText).replace("{{CREATED_AT}}", tweet.created_at).replace("{{USER_NAME_HREF}}", tweet.user.screen_name).replace("{{USER_NAME}}", tweet.user.screen_name).replace("{{USER_NAME_HREF}}", tweet.user.screen_name).replace("{{FULL_NAME}}", tweet.user.name).replace("{{USER_LOCATION}}", tweet.user.location).replace("{{FOLLOWERS_COUNT}}", tweet.user.followers_count);
        return $(template).hide().prependTo("#tweets").slideDown("fast");
      });
      tweetsChannel.bind("star", function(star) {
        return $("#" + star.twid).addClass("starred");
      });
      bucketsChannel.bind("new_bucket", function(bucket) {
        var bucket_element, word_spans;
        word_spans = app.create_word_spans(bucket.words);
        console.log(word_spans);
        bucket_element = $("#bucket-template").html().replace("{{BUCKET_ID}}", bucket.id).replace("{{BUCKET_COUNT}}", $("#spinner-template").html()).replace("{{BUCKET_NAME}}", bucket.name).replace("{{BUCKET_WORDS}}", word_spans);
        return $(bucket_element).hide().prependTo("#buckets").slideDown("fast");
      });
      bucketsChannel.bind("count_bucket", function(bucket_count) {
        return $("#" + bucket_count.id + " .bucket_count").html(app.commaFormat(bucket_count.count));
      });
      return bucketsChannel.bind("recount_bucket", function(new_bucket_count) {
        return $("#" + new_bucket_count.id + " .bucket_count").html(app.commaFormat(new_bucket_count.count));
      });
    },
    create_word_spans: function(words) {
      var str, word, _i, _len;
      str = "";
      for (_i = 0, _len = words.length; _i < _len; _i++) {
        word = words[_i];
        str += "<span class='word'>" + word + "</span>";
      }
      return str;
    }
  };

  $(function() {
    return app.initialize();
  });

}).call(this);
