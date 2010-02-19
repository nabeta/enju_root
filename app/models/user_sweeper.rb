class UserSweeper < ActionController::Caching::Sweeper
  observe User
  def after_save(record)
    ['search', 'message', 'request', 'configuration'].each do |name|
      I18n.available_locales.each do |locale|
        expire_fragment(:controller => :page, :user => name, :menu => name, :locale => locale)
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end
