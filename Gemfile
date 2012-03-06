source :rubygems
gem 'multi_json',      '1.0.4'
gem 'rest-client',     '1.6.7'
gem 'sinatra',         '1.3.2'
gem 'sequel',          '3.33.0'
gem 'rainbows',        '4.3.1'
gem 'rake',            '0.9.2.2'
gem 'hashie',          '1.2.0'
gem 'geoloqi',         '0.9.38'
gem 'sinatra-geoloqi', '0.9.3'
gem 'mysql2',          '0.3.11'

group :development do
  gem 'shotgun', require: nil

  # You may need to type this into your shell for ruby-debug:
  # bundle config build.ruby-debug-base19 --with-ruby-include=$rvm_path/src/ruby-1.9.3-p0
  # Source: http://stackoverflow.com/questions/8087610/ruby-debug-with-ruby-1-9-3
  gem 'linecache19',       '>= 0.5.13'
  gem 'ruby-debug-base19', '>= 0.11.26'
  gem 'ruby-debug19'
end

group :test do
  gem 'minitest',          '2.7.0'
  gem 'rack-test',         '0.6.1',  require: 'rack/test'
  gem 'webmock',           '1.7.7'
  gem 'simplecov',         '0.5.4',  require: nil
  gem 'ruby-debug19',                require: 'ruby-debug'
  gem 'faker',             '1.0.1'
end