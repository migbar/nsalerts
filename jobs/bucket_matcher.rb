class BucketMatcher

  def self.queue; "buckets"; end  
  
  # MATCHING:
       # Run a MATCH as proc { EM.defer BucketMatcher.operation(tweet), BucketMatcher.callback }
       #      -- BucketUpdate operation is kinda like the mongo persist now
       #      -- passes the matched buckets to the callback
       #      -- callback enqueues a proc on each of the matching bucket queues
       #          -- that proc ends with a call to pop on the bucket queue 
       #      -- callback calls pop on each of the matching bucket queues

  def self.perform(args)   
    tweet_id = args[0]      
    Queues.all_queue_ids.each do |q_id|
      Queues.push(q_id, proc{ |id| EM.defer operation(id, tweet_id), callback })
      Queues.pop(q_id)
    end
  end
  
  def self.operation(id, tweet_id)                            
    proc {      
      bucket = find_bucket(id)                           
      tweet = find_tweet(tweet_id)
      if matches?(tweet, bucket)
        add_to_bucket(tweet, id)
        [id, true]
      else
        [id, false]
      end                         
    }
  end    
  
  def self.callback                                                                    
    proc { |id, matched|                               
      op = proc { broadcast_bucket_count(id) if matched }                                                         
      cb = proc { Queues.pop(id) }                                                        
      EM.defer op, cb
    }
  end                      
  
  def self.find_bucket(id)
    buckets.find_one( "_id" => BSON::ObjectId.from_string(id) )
  end       
  
  def self.add_to_bucket(tweet, id)
    buckets.update({"_id" => BSON::ObjectId.from_string(id)}, {"$addToSet" => {"tweets" => tweet["id_str"]}}) 
  end                                                                                  
  
  def self.matches?(tweet, bucket)
    return false unless tweet["text"]                                     
    lines = tweet["text"].split("\n")                                     
    bucket["words"].detect { |w| !lines.grep(Regexp.new(w, true)).empty? }
  end                              
        
  def self.broadcast_bucket_count(id)
    bucket = find_bucket(id) 
    count = bucket["tweets"] ? bucket["tweets"].count : 0            
    Resque.enqueue(Push, "buckets", "count_bucket", {id: id, name: bucket["name"], count: count})
  end
  
  def self.find_tweet(id)
    tweets.find_one( "id_str" => id )
  end
  
  def self.buckets
    MONGOLAB_DB["collectweet.tweet_buckets"]
  end
  
  def self.tweets
    MONGOLAB_DB["collectweet.tweets"]
  end
  
end


     
        