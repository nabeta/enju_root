class PageSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Library, Shelf, Subject, Classification, PictureFile

  def after_save(record)
    case
    when record.is_a?(Library)
      expire_menu
    when record.is_a?(Shelf)
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when record.is_a?(Tag)
      record.taggings.collect(&:taggable).each do |taggable|
        expire_editable_fragment(taggable)
      end
    when record.is_a?(Subject)
      expire_editable_fragment(record)
      record.works.each do |work|
        expire_editable_fragment(work)
      end
      record.classifications.each do |classification|
        expire_editable_fragment(classification)
      end
    when record.is_a?(Classification)
      expire_editable_fragment(record)
      record.subjects.each do |subject|
        expire_editable_fragment(subject)
      end
    when record.is_a?(PictureFile)
      case
      when record.picture_attachable.is_a?(Manifestation)
        expire_editable_fragment(record.picture_attachable, ['picture_file', 'book_jacket'])
      when record.picture_attachable.is_a?(Patron)
        expire_editable_fragment(record.picture_attachable, ['picture_file'])
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_menu
    I18n.available_locales.each do |locale|
      Role.all_cache.each do |role|
        expire_fragment(:controller => :page, :page => 'menu', :role => role.name, :locale => locale)
      end
    end
  end
end
