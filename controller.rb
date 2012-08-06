require './environment.rb'

post '/trigger' do
  payload = Hashie::Mash.new JSON.parse(request.body.read)

  stop_id = payload.place.extra.stop_id
  puts "STOP ID: #{stop_id}"
  stop = Stop[agency: Agency[name: 'miami_dade'], uid: stop_id] # TODO: Put agency in extra

  session = Geoloqi::Session.new({
    client_id: $config.geoloqi_client_id,
    client_secret: $config.geoloqi_client_secret,
    access_token: $config.geoloqi_application_access_token
  })

puts "STOP: #{stop.inspect}"
puts "USER: #{payload.user.user_id}"
puts "TEXT: #{stop.upcoming_times_message}"

  session.post 'message/send', {
    layer_id: payload.layer.layer_id,
    user_id:  payload.user.user_id,
    text:     stop.upcoming_times_message
  }
  # :url => "http://trimet.org/arrivals/small/tracker?locationID=#{body.place.extra.stopid}" IMPLEMENT THIS!!!
  'ok'
end
