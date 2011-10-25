class BucketRecounter

  def self.queue; "buckets"; end  
  
  # RECOUNT:
      # Queue with bucket id exists?
        # NO:  Create queue for it
        # YES: Enqueue a RECOUNT as a proc { EM.defer BucketRecount.operation(id), BucketRecount.callback }
        #      -- callback ends with a call to pop on the bucket queue 
     # pop the queue with that id

  def self.perform(args)
    bucket_id = args[0]            
    # enqueue the recount job for bucket_id      
    Queues.push(bucket_id, proc{ |id| EM.defer(operation(id), callback) })
    Queues.pop(bucket_id)
  end
  
  def self.operation(id)        
    proc {                 
      bucket = find_bucket(id)
      sorted_tweets.each { |tweet| add_to_bucket(tweet, id) if matches?(tweet, bucket) }            
      id
    }  
  end    
  
  def self.callback                                                      
    proc { |id|       
      op = proc { broadcast_bucket_count(id) }                                                         
      cb = proc { Queues.pop(id) }                                                        
      EM.defer op, cb
    }
  end    

  private 
  
  def self.find_bucket(id)
    buckets.find_one( "_id" => BSON::ObjectId.from_string(id) )
  end
  
  def self.add_to_bucket(tweet, id)
    buckets.update({"_id" => BSON::ObjectId.from_string(id)}, {"$addToSet" => {"tweets" => tweet["id_str"]}}) 
  end                                                                                  
  
  def self.matches?(tweet, bucket)
    return false unless tweet["text"]  
    cleaned = tweet["text"].gsub(/\W/i, ' ')
    lines = cleaned.split('\n').collect {|line| line.strip.center(cleaned.size + 2, ' ')}
    !!bucket["words"].detect { |w| !lines.grep(Regexp.new(w.center(w.size + 2, ' '), true)).empty? }
  end                              
  
  def self.broadcast_bucket_count(id)
    bucket = find_bucket(id) 
    count = bucket["tweets"] ? bucket["tweets"].count : 0
    Resque.enqueue(Push, "buckets", "recount_bucket", {id: id, name: bucket["name"], count: count})
  end
  
  def self.sorted_tweets
    tweets = MONGOLAB_DB["collectweet.tweets"] 
    tweets.find({}, sort: "id_str")
  end            
  
  def self.buckets
    MONGOLAB_DB["collectweet.tweet_buckets"]
  end
                  
end