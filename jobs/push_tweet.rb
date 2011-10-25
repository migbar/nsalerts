class PushTweet

  def self.queue; "buckets"; end  
  # 
  # def self.perform(tweet)                        
  #   puts "Broadcasting tweet: #{tweet["text"]}"
  #   msg = Hash.new{ |hash, key| hash[key] = Hash.new(&hash.default_proc) }                                                       
  # 
  #   msg["text"]                      = tweet["text"]    
  #   msg["id_str"]                    = tweet["id_str"]             
  #   msg["created_at"]                = tweet["created_at"]
  #   msg["user"]["name"]              = tweet["user"]["name"]
  #   msg["user"]["location"]          = tweet["user"]["location"]   
  #   msg["user"]["screen_name"]       = tweet["user"]["screen_name"]
  #   msg["user"]["followers_count"]   = tweet["user"]["followers_count"]   
  #   msg["user"]["profile_image_url"] = tweet["user"]["profile_image_url"]
  #   
  #   Pusher['tweets'].trigger('tweet', msg)
  # end     

  def self.perform(args)    
    channel = args[0]
    message_name = args[1]
    tweet = args[2]      
    
    msg = Hash.new{ |hash, key| hash[key] = Hash.new(&hash.default_proc) }                                                       

    msg["text"]                      = tweet["text"]    
    msg["id_str"]                    = tweet["id_str"]             
    msg["created_at"]                = tweet["created_at"]
    msg["user"]["name"]              = tweet["user"]["name"]
    msg["user"]["location"]          = tweet["user"]["location"]   
    msg["user"]["screen_name"]       = tweet["user"]["screen_name"]
    msg["user"]["followers_count"]   = tweet["user"]["followers_count"]   
    msg["user"]["profile_image_url"] = tweet["user"]["profile_image_url"]
    
    puts "trigerring async: channel #{channel}, name: #{message_name} - msg from: #{msg['user']['name']}"
    Pusher[channel].trigger_async(message_name, msg)
  end

end
