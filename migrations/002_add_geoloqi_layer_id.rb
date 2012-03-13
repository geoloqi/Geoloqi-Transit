Sequel.migration do
  up {
    DB.alter_table :agencies do
      add_column :geoloqi_layer_id, String
    end
  }

  down {
    DB.alter_table :agencies do
      drop_column :geoloqi_layer_id
    end
  }
end