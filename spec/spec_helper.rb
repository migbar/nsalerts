# require "rack/test"     
require "rubygems"
require "bundler/setup"
require "resque"
require "resque/server"

require "capybara"
require "capybara/dsl"
require "capybara/rspec"
                           
include Capybara::DSL

require File.dirname(__FILE__) + "/../app.rb"    
# require File.dirname(__FILE__) + "/../buckets.rb" 

require 'pace' 
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f} 
Dir[File.expand_path(File.join(File.dirname(__FILE__),'..','jobs','**','*.rb'))].each {|f| require f} 
Dir[File.expand_path(File.join(File.dirname(__FILE__),'..','models','**','*.rb'))].each {|f| require f} 

# def setup 
  Capybara.app = Collectweet::App
# end

# set :environment, :test