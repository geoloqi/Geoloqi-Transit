require 'csv'

class Agency < Sequel::Model
  one_to_many :routes
  one_to_many :services
  one_to_many :stops
  one_to_many :stop_times
  one_to_many :trips

  ARBITRARY_RADIUS = 321868 # About 200 miles

  def self.create(name, gtfs_path)
    agency = self[name: name]

    if agency.nil?
      acsv = CSV.read(File.join(gtfs_path, 'agency.txt')).last
      real_name = acsv[1]
      agency = super(name: name, 
                     real_name: real_name,
                     url:       acsv[2],
                     time_zone: acsv[3])
puts "NOT IMPORTING TO GEOLOQI"
return
exit
      app_session = Geoloqi::Session.application

      # Get the geocoded center location for the layer.
      geocoded = Geokit::Geocoders::MultiGeocoder.geocode(name)
      latitude,longitude = geocoded.lat, geocoded.lng

      layer_args = {
        key: name,
        name: agency.real_name,
        radius: ARBITRARY_RADIUS,
        latitude: latitude,
        longitude: longitude
      }

      # Check for existing
      layer = app_session.get('layer/list')[:layers].select {|l| l[:name] == real_name}.first

=begin
# Deleting 
      places = app_session.get("place/list?layer_id=#{layer[:layer_id]}&limit=3000")[:places]

      app_session.batch do
        places.each {|p| post "place/delete/#{p[:place_id]}"}
      end
      puts "DUH?"
      exit
=end

      if layer.nil?
        layer = app_session.post 'layer/create', layer_args
      else
        layer = app_session.post "layer/update/#{layer[:layer_id]}", layer_args
      end

      first_row = true
      puts ''

      # Create/update places.

      places_resp = app_session.batch do

        CSV.foreach(File.join(gtfs_path, 'stops.txt')) do |stop|

          if first_row
            first_row = false
            next
          end

          stop_id = stop[0]
          stop_name = stop[2].smart_titleize
          stop_desc = stop[3].smart_titleize
          place_key = "name#{stop_id}"
          place_args = {
            key: place_key,
            latitude: stop[4],
            longitude: stop[5],
            name: "#{stop_name} (Stop ID #{stop[0]})",
            layer_id: layer[:layer_id],
            description: stop_desc,
            radius: stop_name.match(/max/i) ? 25 : 12,
            extra: {
              stop_id: stop_id
            }
          }

          begin
            place = app_session.get("place/info", key: place_key, layer_id: layer[:layer_id])[:place]
          rescue Geoloqi::ApiError => e
            e.type == 'not_found' ? place = nil : fail
          end

          if place.nil?
            place = post 'place/create', place_args
          else
            place = post "place/update/#{place[:place_id]}", place_args
          end

          Kernel.print "#{place_args[:name]}, "
        end

      end
      
      app_session.post 'trigger/create', {
        layer_id: layer[:layer_id],
        type: 'callback',
        callback: $config.trigger_url,
        trigger_after: 20
      }

=begin
      puts "TRIGGERS:"

      triggers_resp = app_session.batch do
        places_resp.each do |p|
          triggers = app_session.get("trigger/list?place_id=#{p[:body][:place_id]}")[:triggers]

          triggers.each do |trigger|
            post "trigger/delete/#{trigger[:trigger_id]}"
          end
          
          post "trigger/create", {
            place_id: p[:body][:place_id],
            type: 'callback',
            callback: $config.trigger_url,
            trigger_after: 20
          }
          
          Kernel.print "T, "
        end
      end
      
      require 'ruby-debug' ; debugger
      
      # Add triggers to places.
=end

      puts 'DONE.'
    end
  end
end