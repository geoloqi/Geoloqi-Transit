
require './environment.rb'

post '/trigger' do
  puts params.inspect
end