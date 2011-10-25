require "rubygems"
require "bundler/setup"

require "tweetstream"
require "resque"
require "resque/tasks"    

require File.dirname(__FILE__) + "/config/env"

require File.dirname(__FILE__) + "/jobs/push_tweet"   
require File.dirname(__FILE__) + "/jobs/bucket_matcher"
require File.dirname(__FILE__) + "/jobs/persist_tweet"  
require File.dirname(__FILE__) + "/jobs/mongo_persist_tweet" 

STDOUT.sync = true


#-- Stream search results from twitter --#

task "tweetstream:stream" => "queue:environment" do
  TweetStream::Client.new(ENV["TWITTER_USERNAME"], ENV["TWITTER_PASSWORD"]).on_error do |message|
    puts "*******************************************************"
    puts "********************* ERROR ***************************"
    puts "*******************************************************"
    puts message
    puts "*******************************************************"
    puts "*******************************************************"
  end.track(ENV["TWITTER_KEYWORD"]) do |tweet|
    # puts "Received tweet: #{tweet[:text]}"
    Resque.enqueue(MongoPersistTweet, tweet) 
    # Resque.enqueue(BucketMatcher, tweet[:id_str])
    # Resque.enqueue(PersistTweet, status)
    Resque.enqueue(PushTweet, "tweets", "tweet", tweet)
  end
end
                                             
#-- Management/config --#

namespace :queue do

  task :environment do
    require File.dirname(__FILE__) + "/config/resque"
  end

  task :clear => :environment do
    [:push, :persist].each do |name|
      Resque.redis.del "queue:#{name}"
    end
  end
end

namespace :resque do

  task :setup => "queue:environment" do
    Resque.after_fork do |job|
      if job.payload_class == PersistTweet
        require File.dirname(__FILE__) + "/config/active_record"
      end
    end
  end
end

namespace :db do

  task :environment do
    load 'config/active_record.rb'
  end

  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

namespace :heroku do
  desc "Export settings out to Heroku"
  task :config do
    puts "Reading config/env.yml and sending config vars to Heroku..."
    config = YAML.load_file('config/env.yml')['production'] rescue {}
    command = "heroku config:add"
    config.each {|key, val| command << " #{key}=#{val} " if val } 
    system command                                                
  end
end
