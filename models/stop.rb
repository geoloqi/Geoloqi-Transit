class Stop < Sequel::Model
  ARBITRARY_RADIUS = 50

  unrestrict_primary_key
  many_to_one :agency
  set_primary_key [:agency_id, :uid]

  one_to_many :stop_times, :class => 'StopTime', :key => [:agency_id, :stop_id]

  # Stop.first.stop_times_dataset.filter('arrival_time > ?', Time.now).limit(3).all

  def upcoming_times_message
    messages = []
    upcoming_stop_times.each do |stop_time|
      route = stop_time.trip.route
      messages << "#{route.short_name} #{route.name} scheduled in #{stop_time.arrival_time_english}"
    end
    #upcoming_stop_times.first.trip.route.name this is old i think
    messages.join ', '
  end

  def upcoming_stop_times
    time_now = TZInfo::Timezone.get(agency.time_zone).utc_to_local(Time.now.utc).strftime('%H:%M:%S')
    service_ids = Service.filter(Time.now.strftime('%A').downcase.to_sym => 1).all.collect {|s| s.uid}
    puts "FIX THE STUPID FALSE NEXT DAY THING"
    ds = stop_times_dataset.filter('arrival_time > ? OR (arrival_time < ? AND next_day = ?)', time_now, time_now, false).order(:arrival_time).limit(3)
#    binding.pry
#    ds.filter!(:service_id => service_ids)
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ #{ds.inspect}"
    ds.all
  end
end
