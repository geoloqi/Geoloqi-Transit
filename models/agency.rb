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
    end
    
    puts "YOU NEED TO RUN THE IMPORTER NOW"
    agency.import_geoloqi_layer
    agency.import_geoloqi_places gtfs_path
  end

  def app_session
    Geoloqi::Session.application
  end

  def import_geoloqi_layer
    puts "IMPORTING TO GEOLOQI"

    # Get the geocoded center location for the layer.
    geocoded = Geokit::Geocoders::MultiGeocoder.geocode(name)
    latitude,longitude = geocoded.lat, geocoded.lng

    layer_args = {
      key: name,
      name: real_name,
      radius: ARBITRARY_RADIUS,
      latitude: latitude,
      longitude: longitude
    }

    # Check for existing
    layer = app_session.get('layer/list')[:layers].select {|l| l[:name] == real_name}.first


    # Deleting start
    places = app_session.get("place/list?layer_id=#{layer[:layer_id]}&limit=3000")[:places]

    app_session.batch do
      places.each {|p| post "place/delete/#{p[:place_id]}"}
    end
    # Deleting end


    if layer.nil?
      layer = app_session.post 'layer/create', layer_args
    else
      layer = app_session.post "layer/update/#{layer[:layer_id]}", layer_args
    end
    
    update geoloqi_layer_id: layer[:layer_id]

    layer_triggers = app_session.get('trigger/list', layer_id: layer[:layer_id])[:triggers]

    layer_triggers.each do |t|
      app_session.post "trigger/delete/#{t[:trigger_id]}"
    end

    app_session.post 'trigger/create', {
      layer_id: layer[:layer_id],
      type: 'callback',
      callback: $config.trigger_url,
      trigger_after: 20
    }
    
    true
  end

  def import_geoloqi_places(gtfs_path)
    first_row = true
    puts ''

    # Create/update places.

    geoloqi_layer_id = self.geoloqi_layer_id

    places_resp = app_session.batch do

      CSV.foreach(File.join(gtfs_path, 'stops.txt')) do |stop|

        if first_row
          first_row = false
          next
        end

        stop_id = stop[0]
        stop_name = stop[2].smart_titleize
        stop_desc = stop[3].smart_titleize unless stop[3].nil?
        place_key = "name#{stop_id}"
        place_args = {
          key: place_key,
          latitude: stop[4],
          longitude: stop[5],
          name: "#{stop_name} (Stop ID #{stop[0]})",
          layer_id: geoloqi_layer_id,
          description: stop_desc,
          radius: Stop::ARBITRARY_RADIUS,
          extra: {
            stop_id: stop_id
          }
        }

        begin
          place = Geoloqi::Session.application.get("place/info", key: place_key, layer_id: geoloqi_layer_id)
        rescue Geoloqi::ApiError => e
          e.type == 'not_found' ? place = nil : fail
        end

        if place.nil?
          place = post 'place/create', place_args
        else
          place = post "place/update/#{place[:place_id]}", place_args
        end
        
        Kernel.print "#{place.nil? ? 'CREATING' : 'UPDATING'} #{place_args[:name]}, "
      end

    end

    puts 'DONE.'
  end
end
