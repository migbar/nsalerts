load "config/active_record.rb"
load "config/index_tank.rb"

class Tweet < ActiveRecord::Base
  after_create do |tweet| 
    puts "The last tweet id is: #{Tweet.last.tweet_id} - Total count: #{Tweet.count}"
    # puts "Indexing tweet: #{tweet["text"]}"
    # $index.document(tweet.to_param).add(:text => tweet.text, :user => tweet.user, :tweet_id => tweet.tweet_id)
  end      
end    
