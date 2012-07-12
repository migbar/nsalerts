require 'uri'
require 'mongo'

MONGOLAB_URI  = URI.parse(URI.encode(ENV['MONGOLAB_URI']))         
MONGOLAB_CONN = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
MONGOLAB_DB   = MONGOLAB_CONN.db(MONGOLAB_URI.path.gsub(/^\//, ''))