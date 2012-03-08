class Integer
    def singular_or_plural
      self == 1 ? '' : 's'
    end
end