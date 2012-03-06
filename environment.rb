ENV['RACK_ENV'] ||= 'development'
Encoding.default_internal = 'UTF-8'
require 'bundler/setup'
Bundler.require
require 'logger'

unless File.exists? './config.yml'
  puts 'Please provide a config.yml file.'
  exit false
end

$config = Hashie::Mash.new YAML.load_file('./config.yml')[ENV['RACK_ENV'].to_s]

DB = Sequel.connect $config.database_url, max_connections: 4, encoding: 'utf8'

require_folders = %w{lib/**}

# Skip model loading for bootstrapping.
require_folders << 'models' unless $skip_models == true

Dir.glob(require_folders.map! {|d| File.join d, '*.rb'}).each {|f| require_relative f}

DB.loggers << Logger.new($stdout) if Sinatra::Base.development?

require './controller.rb'