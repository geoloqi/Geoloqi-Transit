require 'csv'

Thread.abort_on_exception = true

module Geoloqi
  class GTFS
    attr_reader :name, :gtfs_path
    def initialize(name, gtfs_path)
      @name = name
      @gtfs_path = gtfs_path
      @agency = Agency[name: @name]
      
      @pool = Pool.new 15
    end

    def gtfs_file_full_path(resource)
      File.join @gtfs_path, @name, "#{resource}.txt"
    end

    def foreach(resource, &block)
      first_row = true
      CSV.foreach(gtfs_file_full_path(resource)) do |srow|
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

        @pool.schedule do
          @agency.add_stop({
            uid:  srow[0], 
            name: srow[2].smart_titleize, 
            desc: (srow[3].nil? ? nil : srow[3].smart_titleize),
            lat:  srow[4],
            lng:  srow[5]}) if stop.nil?
        end

        # print "#{srow[0].to_s}, "
      end

      Kernel.print " done!\n"
    end
    
    def load_stop_times
      Kernel.print 'Importing stop times...'

      StopTime.filter(agency: @agency).destroy

      foreach 'stop_times' do |s|
        attempt = 0

        @pool.schedule do

          stop_time = StopTime.new agency: @agency
          begin
            stop_time.set({
              stop_id: s[3],
              trip_id: s[0],
              arrival_time: s[1]
            })
            stop_time.save
          rescue => e
            if e.message.match /argument out of range/
              if attempt == 0
                attempt = 1

                # Some times are past midnight (ex: "25:00:13"), so let's try to fix that.
                s[1].match(/^\d+/) {|h| s[1].gsub! /^\d+/, (h.to_s.to_i-24).to_s}
                retry
              else
                fail
              end
            end
          end

        end

      end
      Kernel.print " done!\n"
    end

    def load_trips
      Kernel.print 'Importing trip times...'
      Trip.filter(agency: @agency).destroy

      foreach 'trips' do |t|
        
        @pool.schedule do  
          @agency.add_trip({
            uid:        t[2],
            route_id:   t[0],
            service_id: t[1],
            direction:  t[3]
          })
        end

        # Kernel.print "#{t[2]}, "
      end

      Kernel.print " done!\n"
    end


    def load_services
      Kernel.print 'Import trip times (services from calendar file)...'
      Service.filter(agency: @agency).destroy

      if !File.exist?(gtfs_file_full_path('calendar'))
        puts "No calendar GTFS file exists, skipping"
        return false
      end

      foreach 'calendar' do |s|
        @agency.add_service({
          uid:        s[0],
          monday:     s[1],
          tuesday:    s[2],
          wednesday:  s[3],
          thursday:   s[4],
          friday:     s[5],
          saturday:   s[6],
          sunday:     s[7],
          start_date: Time.parse(s[8].to_s),
          end_date:   Time.parse(s[9].to_s)
        })

        Kernel.print "#{s[2]}, "
      end

      Kernel.print " done!\n"
    end

    def load_routes
      Kernel.print 'Importing route times...'
      Route.filter(agency: @agency).destroy

      foreach 'routes' do |r|
        @pool.schedule do
          @agency.add_route({
            uid:        r[0],
            short_name: r[2].strip,
            name:       r[3].smart_titleize
          })
        end

        # Kernel.print "#{r[2]}, "
      end

      Kernel.print " done!\n"
    end

    def load_into_database!
     load_stops
     load_routes
     load_trips
     load_stop_times
     load_services
    end
  end
end
