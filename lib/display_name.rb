module DisplayName
  def display_name(locale = I18n.locale)
    name = self.serialized_name[locale] || self.name
    name.strip
  end

  def serialized_name
    locales = self.name.dup.split("\n").map{|n| n.split(':', 2)}.flatten
    Hash[*locales]
  rescue
    {}
  end
end
