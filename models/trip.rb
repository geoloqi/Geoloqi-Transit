class Trip < Sequel::Model
  unrestrict_primary_key
  set_primary_key [:agency_id, :uid]
  many_to_one :agency
  # one_to_many :stop_times, :class => 'StopTime', :key => [:agency_id, :stop_id]
  many_to_one :route, :class => 'Route', :key => [:agency_id, :route_id]
end
