require "rubygems"
require "bundler/setup"

require "tweetstream"
require "resque"
require "resque/tasks"    

require "nestful"

require File.dirname(__FILE__) + "/config/env"

require File.dirname(__FILE__) + "/jobs/push_tweet"   
require File.dirname(__FILE__) + "/jobs/bucket_matcher"
require File.dirname(__FILE__) + "/jobs/persist_tweet"  
require File.dirname(__FILE__) + "/jobs/mongo_persist_tweet" 

STDOUT.sync = true


#-- Stream search results from twitter --#

task "tweetstream:stream" => "queue:environment" do
  puts "before tweet stream client #{ENV["TWITTER_KEYWORD"]} #{ENV["TWITTER_USERNAME"]}, #{ENV["TWITTER_PASSWORD"]}"
  TweetStream::Client.new(ENV["TWITTER_USERNAME"], ENV["TWITTER_PASSWORD"]).on_error do |message|
    puts "*******************************************************"
    puts "********************* ERROR ***************************"
    puts "*******************************************************"
    puts message
    puts "*******************************************************"
    puts "*******************************************************"
  end.track(ENV["TWITTER_KEYWORD"]) do |tweet|
    puts "Received tweet: #{tweet[:text]}"
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
  puts "Resque is #{Resque}"
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

def post_message(url, text="Empty Message")
  msg = Hash.new{ |hash, key| hash[key] = Hash.new(&hash.default_proc) }

  msg["text"]                         = text
  msg["id_str"]                       = "#{Time.now.to_i}"
  msg["created_at"]                   = Time.utc(*Time.new.to_a).to_s
  msg["user"]["name"]                 = "Joe Netstar"
  msg["user"]["location"]             = "Montvale, NJ"
  msg["user"]["screen_name"]          = "netstar_user"
  msg["user"]["followers_count"]      = "12345"
  msg["user"]["profile_image_url"]    = "http://a1.twimg.com/profile_images/314644552/3218_1074491953775_1570471322_30186690_2935445_n_normal.jpg"

  Nestful.post url, :format => :json, :params => {:message => msg}
end

namespace :messages do
  namespace :prod do
    desc "Create a message in production manually"
    task :create, :text do |t, args|
      post_message('http://nsalerts.herokuapp.com/messages.json', args[:text])
    end  
  end              
   
  namespace :dev do 
    desc "Create a message in development manually"
    task :create, :text do |t, args|
      post_message('http://localhost:5000/messages.json', args[:text])
    end    
  end
end
