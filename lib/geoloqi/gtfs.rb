# Module to extend Geoloqi::Session to do gtfs stops import
module Geoloqi::GTFS

  def import_gtfs_stops(layer_name, stop_file_path)

  end

  def self.import(session, path)
    file = File.new(path, 'r')

    #Setup a batch
    batches = {
       access_token: $config.application_access_token,
       batch: []
    }
  end
end