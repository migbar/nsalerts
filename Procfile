web:      bundle exec thin start -p $PORT -e $RACK_ENV
stream:   bundle exec rake tweetstream:stream --trace   
mongo:    bundle exec rake resque:work QUEUE=mongo_persist --trace
buckets:  bundle exec ruby buckets.rb --trace
                                   