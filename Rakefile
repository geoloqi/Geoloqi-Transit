require 'rake/testtask'

# To run tests in the order of a seed: bundle exec rake test TESTOPTS="--seed=987"
Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

def init_env
  require './environment.rb'
end

def init_env_for_migrations
  $skip_models = true
  init_env
  Sequel.extension :migration
end

namespace :db do
  desc 'bootstrap the database'
  task :bootstrap do
    init_env_for_migrations

    DB.loggers = []

#    unless %w{development test}.include? ENV['RACK_ENV'].to_s
#      puts "You cannot run db:bootstrap on production for safety reasons."
#      exit 1
#    end

    Sequel::Migrator.apply DB, './migrations', 0
    Sequel::Migrator.apply DB, './migrations'

    Dir.require_multiple 'models'
    init_env

    session = Geoloqi::Session.new :config => {client_id: $config.geoloqi_client_id,
                                               client_secret: $config.geoloqi_client_secret},
                                   :access_token => ''

    #Agency.create 'austin', './files/gtfs/austin'
    Agency.create 'miami_dade', './files/gtfs/miami_dade'

    #gtfs_austin = Geoloqi::GTFS.new 'austin', './files/gtfs'
    #gtfs_austin.load_into_database!

    #gtfs_portland = Geoloqi::GTFS.new 'portland', './files/gtfs'
    #gtfs_portland.load_into_database!

    gtfs_miami_dade = Geoloqi::GTFS.new 'miami_dade', './files/gtfs'
    gtfs_miami_dade.load_into_database!
  end

  desc 'migrate the database to the latest revision'
  task :migrate do
    init_env_for_migrations
    Sequel::Migrator.apply DB, './migrations'
  end
end
