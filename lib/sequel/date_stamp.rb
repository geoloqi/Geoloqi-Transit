module Sequel
  module DateStamp
    def before_create
      if self.class.columns.include? :date_created
        self.date_created ||= Time.now
      end
      super
    end    

    def before_save
      return unless defined?(self.date_modified)
      self.date_modified = Time.now
      super
    end

    def to_api_hash
      api_hash = super

      [:date_created, :date_modified].each do |date_column|
        if api_hash[date_column]
          api_hash["#{date_column}_ts".to_sym] = api_hash[date_column].to_i
          api_hash[date_column] = api_hash[date_column].iso8601
        end
      end

      api_hash
    end
  end

  Model.include DateStamp
end