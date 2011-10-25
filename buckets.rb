require "rubygems"
require "bundler/setup" 
require "resque"
require "pusher"
require "pace"                                                                   

require File.dirname(__FILE__) + "/config/env"
require File.dirname(__FILE__) + "/config/resque"
require File.dirname(__FILE__) + "/jobs/queues"        
require File.dirname(__FILE__) + "/jobs/push"  
require File.dirname(__FILE__) + "/jobs/push_tweet"
require File.dirname(__FILE__) + "/jobs/bucket_recounter"  
require File.dirname(__FILE__) + "/jobs/bucket_matcher"  
require File.dirname(__FILE__) + "/config/mongo_config"       
require File.dirname(__FILE__) + "/config/pusher_config"    

STDOUT.sync = true

# with my hacked version of pace, the subscriber class will get notified (Queues#tick) whenever the pace timer runs. 
opts = {:queue => "buckets", :subscriber => Queues}
opts[:url] = ENV['REDISTOGO_URL'] if ENV['REDISTOGO_URL']  
                                          
Queues.load_queues

Pace.start(opts) do |job| 
  klass = Kernel.const_get job["class"]
  work = job["args"] 
  
  klass.perform work   
end


