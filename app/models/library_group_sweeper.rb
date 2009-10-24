class LibraryGroupSweeper < ActionController::Caching::Sweeper
  observe LibraryGroup
  def after_save(record)
    expire_fragment(:controller => 'library_groups', :id => record.id, :action_suffix => 'header')
  end

  def after_destroy(record)
    after_save(record)
  end
end
