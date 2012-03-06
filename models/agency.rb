require 'csv'

class Agency < Sequel::Model
  def self.create(name, gtfs_path)
    require 'ruby-debug' ; debugger
    agency = self[name: name]

    if agency.nil?
      acsv = CSV.read(File.join(gtfs_path, 'agency.txt')).last
      agency = super(name: name, 
                     real_name: acsv[1],
                     url:       acsv[2],
                     time_zone: acsv[3])
                     
      app_session = Geoloqi::Session.application

      resp = app_session.batch do        
        CSV.foreach(File.join(gtfs_path, 'stops.txt')) do |stop|
          post 'place/create', {
            latitude: stop[4],
            longitude: stop[5],
            name: "#{columns[2]} (Stop ID #{columns[0]})",
            layer_id: layer_id,
            description: columns[3],
            radius: columns[2].include?("MAX") ? 25 : 12,
            extra: {
              stop_id: columns[0]
            }
          }
          puts "Line No. #{file.lineno} : #{columns[2]} (StopID #{columns[0]})"
        end
      end
      
      puts "resp: #{resp.inspect}"
    end
  end

end