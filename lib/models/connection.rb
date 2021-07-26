require 'erb'

connection_details = YAML::load(ERB.new(File.read('db/config.yml')).result)
ActiveRecord::Base.establish_connection(connection_details[ENV['ENV']])


