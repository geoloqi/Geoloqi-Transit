class Service < Sequel::Model
  many_to_one :agency
end