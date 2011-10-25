source "http://rubygems.org"

gem "thin"
gem "rake"
gem "sinatra"
gem "pusher"
                                                                 
gem "twitter-stream", :git => "git://github.com/migbar/twitter-stream.git"

gem "tweetstream"
gem "clockwork"
gem "resque"
gem "activerecord", "~>3.0.9"    

gem "heroku"

gem "mongo"
gem "bson_ext"

# gem "indextank"     

gem "em-http-request"
gem "pace"

gem 'yajl-ruby' #prevents encoding exceptions 

gem "nestful"

group :development, :test do
  gem "sqlite3"        
  gem 'guard-rspec'               
end                

group :test do
  gem "rspec"   
  gem "capybara"   
  gem "guard"
  gem 'rb-fsevent'
  gem 'growl_notify'
end
            
group :production do
  gem "newrelic_rpm"
  gem "pg"
end
