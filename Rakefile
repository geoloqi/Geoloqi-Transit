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

    unless %w{development test}.include? ENV['RACK_ENV'].to_s
      puts "You cannot run db:bootstrap on production for safety reasons."
      exit 1
    end

    Sequel::Migrator.apply DB, './migrations', 0
    Sequel::Migrator.apply DB, './migrations'

    Dir.require_multiple 'models'
    init_env
    
    create_agency 'austin', './files/gtfs/austin'
  end

  desc 'migrate the database to the latest revision'
  task :migrate do
    init_env_for_migrations
    Sequel::Migrator.apply DB, './migrations'
  end
end
