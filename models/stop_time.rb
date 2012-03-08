class StopTime < Sequel::Model
  ONE_MINUTE = 60.freeze
  ONE_HOUR = (ONE_MINUTE * 60).freeze
  ONE_DAY = (ONE_HOUR * 24).freeze

  many_to_one :agency
  many_to_one :stop, :class => 'StopTime', :key => :uid
  many_to_one :trip, :class => 'Trip',     :key => [:agency_id, :trip_id]

  # schedule to arrive in FILL_IN
  def arrival_time_english
    time_now = Time.now
    arrives_in = Time.parse(arrival_time.strftime('%H:%M:%S')) - time_now

    if arrives_in < ONE_MINUTE
      return 'less than a minute'
    elsif arrives_in < ONE_HOUR
      hours = arrives_in.to_f / ONE_HOUR
      minutes = ((hours - hours.floor) * ONE_MINUTE).to_i
      
      return "#{(arrives_in / ONE_MINUTE).round} minutes"
    elsif arrives_in < ONE_DAY
      hours = arrives_in.to_f / ONE_HOUR
      minutes = ((hours - hours.floor) * ONE_MINUTE).to_i
      
      return "#{(arrives_in/ONE_HOUR).round} hours"
    else
      return "#{(arrives_in/ONE_HOUR).round} hours"
    end
  end
end