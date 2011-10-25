require 'active_record'
require 'logger'
require 'erb'

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Migration.verbose = true

if ENV['DATABASE_URL']  
  db = URI.parse(ENV['DATABASE_URL'])

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
else
  dbconfig = YAML.load(ERB.new(File.read('config/database.yml')).result)
  ActiveRecord::Base.establish_connection dbconfig[ENV['RACK_ENV'] || 'development']        
end