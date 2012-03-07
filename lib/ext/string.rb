class String
  ARTICLE_WORDS = %w{a an the}.freeze
  COORDINATING_CONJUNCTIONS = %w{and but or for nor}.freeze
  PREPOSITIONS = %w{aboard about above across after against along amid among around as at atop before behind below beneath beside between beyond by despite down during for from in inside into like near of off on onto out outside over past regarding round since than through throughout till to toward under unlike until up upon with within without}.freeze
  LOWERCASE_TITLE_WORDS = (ARTICLE_WORDS+COORDINATING_CONJUNCTIONS+PREPOSITIONS).freeze

  def smart_titleize
    self.gsub(/\w+/) {|w| w.capitalize}.gsub(/ #{LOWERCASE_TITLE_WORDS.join ' | '} /i) {|w| w.downcase}
  end
end