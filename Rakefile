require 'bundler/setup'
require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

Dir["./lib/**/*.rb"].each {|file| require file }

task :check_broken_links do
  Batcher.run
end
