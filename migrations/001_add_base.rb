Sequel.migration do
  up {
    DB.create_table :agencies do
      primary_key :id
      String      :name
      String      :real_name
      String      :url
      String      :time_zone

      Time        :date_created
      Time        :date_modified
      Boolean     :is_deleted, default: false
    end

    DB.create_table :stops do
      primary_key :id
      Integer     :agency_id
      Integer     :uid
      String      :name
      String      :desc
      String      :lat
      String      :lng

      Time        :date_created
      Time        :date_modified
      Boolean     :is_deleted, default: false
    end
    
    DB.create_table :stop_times do
      primary_key :id
      Integer     :agency_id
      Integer     :stop_id
      Integer     :trip_id
      column      :arrival_time, :time
      Time        :date_created
      Time        :date_modified
      Boolean     :is_deleted, default: false
    end
    
    DB.create_table :trips do
      primary_key :id
      Integer     :agency_id
      Integer     :uid
      Integer     :route_id
      Integer     :service_id
      String      :direction
      
      Time        :date_created
      Time        :date_modified
      Boolean     :is_deleted, default: false
    end
    
    DB.create_table :routes do
      primary_key :id
      Integer     :agency_id
      Integer     :uid
      String      :name
      
      Time        :date_created
      Time        :date_modified
      Boolean     :is_deleted, default: false
    end

=begin
# This is connected to calendars.txt, it shows when routes will be open.. or something
    DB.create_table :services do
      primary_key :id      
    end
=end

  }

  down {
    DB.drop_table :agencies
    DB.drop_table :stops
    DB.drop_table :stop_times
    DB.drop_table :trips
    DB.drop_table :routes

    # DB.drop_table :services
  }
end