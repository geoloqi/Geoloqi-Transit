class Route < Sequel::Model
  unrestrict_primary_key
  set_primary_key [:agency_id, :uid]
  many_to_one :agency
end
