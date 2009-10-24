class LibraryGroupSweeper < ActionController::Caching::Sweeper
  observe LibraryGroup
  def after_save(record)
    expire_fragment(:library_group_id => record.id)
  end

  def after_destroy(record)
    after_save(record)
  end
end
