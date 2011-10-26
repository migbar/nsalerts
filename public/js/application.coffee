app = 
  initialize: ->
    app.setupStars()
    app.setupBucketForm()
    app.setupManifest()
    app.setupPusher()
    app.addCommas()  
    
  setupStars: ->
    console.log "setting up STARS !!!!!!" 
    $(".star").live 'click', (e) ->                   
      e.preventDefault()
      app.notifyStar this
      
  notifyStar: (star) ->
    $.ajax 
      type: "POST"
      url: "/stars.json"
      dataType: "json"
      contentType: "application/json"
      data: JSON.stringify {"tweet_id": $(star).parents('.tweet').attr('id')}                          
      
      success: (data, textStatus) => 
        $(star).parents('.tweet').addClass "starred"
        # $(this).fadeOut('slow')  # Don't hide it just yet ... maybe a toggle with an undo?      

  setupBucketForm: -> 
    $('#new_bucket_form').ajaxForm (data, textStatus) -> 
      $(':input','#new_bucket_form').not(':button, :submit, :reset, :hidden').val('')
      $('.mf_list li').remove()   

  format: (countElement) -> 
    element = $(countElement)
    element.html(app.commaFormat(element.html()))
      
  commaFormat: (nStr) ->                         
    console.log("formatting count for ", nStr)
    nStr += ""
    x = nStr.split(".")
    x1 = x[0]
    x2 = (if x.length > 1 then "." + x[1] else "")
    rgx = /(\d+)(\d{3})/
    while rgx.test(x1)
      x1 = x1.replace(rgx, "$1" + "," + "$2")
    x1 + x2      
    
  addCommas: ->         
    app.format(count) for count in $(".bucket_count")
    
  setupManifest: ->
    $('#bucket_words').manifest()  
    
  setupPusher: ->  
    pusher = new Pusher($('#pusher_api').html())
    tweetsChannel = pusher.subscribe("tweets")
    bucketsChannel = pusher.subscribe("buckets")  
    
    tweetsChannel.bind "tweet", (tweet) ->
      linkifiedText = $("<p>" + tweet.text + "</p>").linkify().html()
      template = $("#tweet-template").html().replace("{{TWEET_ID_STR}}", tweet.id_str).replace("{{PROFILE_IMAGE}}", tweet.user.profile_image_url).replace("{{TEXT}}", linkifiedText).replace("{{CREATED_AT}}", tweet.created_at).replace("{{USER_NAME_HREF}}", tweet.user.screen_name).replace("{{USER_NAME}}", tweet.user.screen_name).replace("{{USER_NAME_HREF}}", tweet.user.screen_name).replace("{{FULL_NAME}}", tweet.user.name).replace("{{USER_LOCATION}}", tweet.user.location).replace("{{FOLLOWERS_COUNT}}", tweet.user.followers_count)
      $(template).hide().prependTo("#tweets").slideDown "fast"

    tweetsChannel.bind "star", (star) ->
      $("#" + star.twid).addClass "starred"

    bucketsChannel.bind "new_bucket", (bucket) ->
      word_spans = (app.create_word_spans bucket.words) 
      console.log word_spans
      bucket_element = $("#bucket-template").html().replace("{{BUCKET_ID}}", bucket.id).replace("{{BUCKET_COUNT}}", $("#spinner-template").html()).replace("{{BUCKET_NAME}}", bucket.name).replace("{{BUCKET_WORDS}}", word_spans)
      # bucket_element.replace("{{BUCKET_WORDS}}", "<span>word_spans</span")  
      $(bucket_element).hide().prependTo("#buckets").slideDown "fast"

    bucketsChannel.bind "count_bucket", (bucket_count) ->
      $("#" + bucket_count.id + " .bucket_count").html app.commaFormat(bucket_count.count)

    bucketsChannel.bind "recount_bucket", (new_bucket_count) ->
      $("#" + new_bucket_count.id + " .bucket_count").html app.commaFormat(new_bucket_count.count) 
      
  create_word_spans: (words) ->
    str = ""
    for word in words                           
      str += "<span class='word'>#{word}</span>"
    str  
    
$ ->
  app.initialize()