class Route < Sequel::Model
  many_to_one :agency
end