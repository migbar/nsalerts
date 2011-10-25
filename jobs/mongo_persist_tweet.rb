require "pusher"

require File.dirname(__FILE__) + "/../config/resque"       
require File.dirname(__FILE__) + "/../config/mongo_config"       

class MongoPersistTweet
  @queue = :mongo_persist  
  
  def self.perform(tweet)                   
    save(tweet)          
    bucket_matches(tweet)                       
  end      
  
  private
  
  def self.save(tweet)
    tweets.insert(tweet)                                                              
  end                     
  
  def self.bucket_matches(tweet)              
    Resque.enqueue(BucketMatcher, tweet["id_str"])
  end 

  def self.tweets
    MONGOLAB_DB["collectweet.tweets"]
  end   

end
