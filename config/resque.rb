if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"]) 
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = Redis.new
end