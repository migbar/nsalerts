require File.dirname(__FILE__) + "/../config/resque"
require File.dirname(__FILE__) + "/../models/tweet"

class PersistTweet

  @queue = :persist

  def self.perform(tweet)                                                                              
    puts "Saving tweet(#{tweet["id"]}): #{tweet["text"]}"
    Tweet.create!(:user => tweet["user"]["screen_name"], :text => tweet["text"], :tweet_id => tweet["id"].to_s)
  end

end
