require "sinatra/base"
require "uri"
require "json"                                

require File.dirname(__FILE__) + "/config/env"
require File.dirname(__FILE__) + "/config/resque"
require File.dirname(__FILE__) + "/jobs/push"          
require File.dirname(__FILE__) + "/jobs/bucket_recounter"          
require File.dirname(__FILE__) + "/config/mongo_config" 

# for POST messages.json - hello
require File.dirname(__FILE__) + "/jobs/mongo_persist_tweet"
require File.dirname(__FILE__) + "/jobs/push_tweet"
                          
module Collectweet
  class App < Sinatra::Base
    set :static, true
    set :public, 'public'
    
    # use Rack::Auth::Basic, "Restricted Area" do |username, password|
    #   [username, password] == [ENV["WEB_USERNAME"], ENV["WEB_PASSWORD"]]
    # end   

    get "/" do  
      protected!
      erb :index
    end
     
    post "/messages.json" do
      m = JSON.parse(request.body.read)["message"]
      persist_message m
      broadcast_message m
      success
    end
    
    post "/stars.json" do   
      protected!
      twid = JSON.parse(request.body.read)["tweet_id"] 
      add_star(twid)
      broadcast_star(twid)
      success  
    end
    
    post "/buckets.json" do  
      protected!
      case params["action"]
      when "add" 
        broadcast_bucket(add_bucket) unless real_words.empty?     
      when "remove"
        remove_bucket
      end                 
      success
    end

    get "/bad" do
      failure
    end

    helpers do
      def pusher_api_key      
        ENV["PUSHER_API_KEY"]  
      end
      
      def all_buckets
        MONGOLAB_DB["collectweet.tweet_buckets"].find()
      end 
      
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["WEB_USERNAME"], ENV["WEB_PASSWORD"]]
      end
      
    end
    
    private 
    
    def add_star(twid)
      MONGOLAB_DB["collectweet.tweets"].update({"id_str" => twid}, {"$set" => {"star" => true}})    
    end                                                
    
    def broadcast_star(twid)
      Resque.enqueue(Push, "tweets", "star", {"twid" => twid} )
    end                   
    
    def add_bucket                       
      MONGOLAB_DB["collectweet.tweet_buckets"].insert("name" => params["name"], "words" => real_words)
    end                        
    
    def real_words       
      # This weirdness in the params comes from the way the manifest jQuery plugin behaves.
      # The last word comes in separately in params["words"] if they just hit enter
      # All the other comma-separated ones come in the params["words_values"]
      words = params["words_values"] || []
      words << params["words"]                                                                
      words.map(&:strip).compact.reject(&:empty?).to_set.to_a
    end
    
    def broadcast_bucket(id)                                                    
      bucket = MONGOLAB_DB["collectweet.tweet_buckets"].find_one("_id" => id)      
      Resque.enqueue(Push, "buckets", "new_bucket", {"id" => id.to_s, "name" => bucket["name"], "words" => bucket["words"]})
      Resque.enqueue(BucketRecounter, id.to_s)
    end                                                                                                                   
    
    def remove_bucket
      # remove bucket 
      # id = params["id"]
    end            
    
    def persist_message(message) 
      Resque.enqueue(MongoPersistTweet, message)
    end
    
    def broadcast_message(message)
      Resque.enqueue(PushTweet, "tweets", "tweet", message)
    end
    
    def success(response = ["ok"])
      content_type "application/json"
      return response.to_json
    end       
    
    def failure
      raise "this is an error"
    end

  end
end
