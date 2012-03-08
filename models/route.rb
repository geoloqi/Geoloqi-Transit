class Route < Sequel::Model
  set_primary_key [:agency_id, :uid]
  many_to_one :agency
end