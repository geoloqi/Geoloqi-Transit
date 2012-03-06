module Geoloqi
  class Session
    def self.application
      self.new({
        config: {
          client_id:     $config.geoloqi_client_id,
          client_secret: $config.geoloqi_client_secret
        },
        access_token: $config.geoloqi_application_access_token
      })
    end
  end
end