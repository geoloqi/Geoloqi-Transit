require 'csv'

module Geoloqi
  class GTFS
    attr_reader :name, :gtfs_path
    def initialize(name, gtfs_path)
      @name = name
      @gtfs_path = gtfs_path
      @agency = Agency[name: @name]
    end

    def foreach(resource, &block)
      first_row = true
      CSV.foreach(File.join(@gtfs_path, @name, "#{resource}.txt")) do |srow|
        if first_row
          first_row = false
          next
        end

        yield srow
      end
    end


    def load_stops
      Kernel.print 'Importing stops...'

      foreach 'stops' do |srow|
        stop = Stop[agency: @agency, uid: srow[0]]

        @agency.add_stop({
          uid:  srow[0], 
          name: srow[2].smart_titleize, 
          desc: srow[3].smart_titleize,
          lat:  srow[4],
          lng:  srow[5]}) if stop.nil?
        
        print "#{srow[0].to_s}, "
      end

      Kernel.print " done!\n"
    end
    
    def load_stop_times
      Kernel.print 'Import stop times...'

      StopTime.filter(agency: @agency).destroy

      foreach 'stop_times' do |s|

        @agency.add_stop_time({
          stop_id:      s[3],
          trip_id:      s[0],
          arrival_time: s[1]
        })

        print "#{s[0].to_s}, "
      end
      Kernel.print " done!\n"
    end

    def load_trips
      Kernel.print 'Import trip times...'
      Trip.filter(agency: @agency).destroy

      foreach 'trips' do |t|
        @agency.add_trip({
          uid:        t[2],
          route_id:   t[0],
          service_id: t[1],
          direction:  t[3]
        })

        Kernel.print "#{t[2]}, "
      end

      Kernel.print " done!\n"
    end
    
=begin
# TODO THIS IS NOT IMPLEMENTED YET
    def load_services
      Kernel.print 'Import trip times...'
      Service.filter(agency: @agency).destroy

      foreach 'services' do |s|
        @agency.add_service({
          
        })

        Kernel.print "#{s[2]}, "
      end

      Kernel.print " done!\n"
    end
=end

    def load_routes
      Kernel.print 'Import trip times...'
      Route.filter(agency: @agency).destroy

      foreach 'routes' do |r|
        @agency.add_route({
          uid:        r[0],
          name:       r[2]
        })

        Kernel.print "#{t[2]}, "
      end

      Kernel.print " done!\n"
    end

    def load_into_database!
      load_stops
      load_stop_times
      load_trips
      load_routes
    end

  end
end
