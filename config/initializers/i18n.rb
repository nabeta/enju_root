unless RAILS_ENV == 'test'
  I18n.default_locale = "ja"
else
  I18n.default_locale = "en"
end
