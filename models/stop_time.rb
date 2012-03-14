class StopTime < Sequel::Model
  ONE_MINUTE = 60.freeze
  ONE_HOUR = (ONE_MINUTE * 60).freeze
  ONE_DAY = (ONE_HOUR * 24).freeze

  many_to_one :agency
  many_to_one :stop, :class => 'StopTime', :key => :uid
  many_to_one :trip, :class => 'Trip',     :key => [:agency_id, :trip_id]

  # schedule to arrive in FILL_IN
  def arrival_time_english
 #   time_now = Time.now
    time_now = Time.at(Time.now.utc + Time.zone_offset(TZInfo::Timezone.get(agency.time_zone).current_period.offset.abbreviation.to_s))
    arrives_in = Time.parse(arrival_time.strftime('%H:%M:%S')) - time_now

    if arrives_in <= ONE_MINUTE
      return 'less than a minute'
    elsif arrives_in < ONE_HOUR
      #hours = arrives_in.to_f / ONE_HOUR
      #minutes = ((hours - hours.floor) * ONE_MINUTE).to_i
      
      minutes = (arrives_in / ONE_MINUTE).round
      
      return "#{minutes} minute#{minutes.singular_or_plural}"
    elsif arrives_in < ONE_DAY
      hours = (arrives_in.to_f / ONE_HOUR).to_f
      minutes = ((hours - hours.floor) * ONE_MINUTE).to_i
      
      response = "#{hours.round} hour#{hours.round.singular_or_plural}"

      if minutes != 0
        response += " #{minutes} minute#{minutes.singular_or_plural}"
      end

      return response
    else
      return "#{(arrives_in/ONE_HOUR).round} hours"
    end
  end
end
