class ResourceSweeper < ActionController::Caching::Sweeper
  observe Manifestation, Item, Expression, Work, Reify, Embody, Exemplify,
    Create, Realize, Produce, Own, BookmarkedResource, Bookmark, Tag, Patron,
    Library, Basket, Checkin

  def after_save(record)
    case
    when record.is_a?(Patron)
      expire_editable_fragment(record)
      record.works.each do |work|
        expire_editable_fragment(work)
      end
      record.expressions.each do |expression|
        expire_editable_fragment(expression)
      end
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
      record.donated_items.each do |item|
        expire_editable_fragment(item)
      end
    when record.is_a?(Work)
      expire_editable_fragment(record)
      record.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
    when record.is_a?(Expression)
      expire_editable_fragment(record)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(Manifestation)
      expire_editable_fragment(record)
      record.expressions.each do |expression|
        expire_editable_fragment(expression)
      end
      record.items.each do |item|
        expire_editable_fragment(item)
      end
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
    when record.is_a?(Item)
      expire_editable_fragment(record)
      expire_editable_fragment(record.manifestation, 'show_holding')
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
      record.donors.each do |donor|
        expire_editable_fragment(donor)
      end
    when record.is_a?(Library)
      expire_fragment(:controller => :libraries, :action => :index, :action_suffix => 'menu')
    when record.is_a?(Shelf)
      record.items.each do |item|
        expire_editable_fragment(item)
      end
    when record.is_a?(Bookmark)
      # Not supported by Memcache
      # expire_fragment(%r{manifestations/\d*})
      expire_editable_fragment(record.bookmarked_resource.manifestation)
      expire_fragment(:controller => :tags, :action => :index, :action_suffix => 'user_tag_cloud', :user_id => record.user.login)
      expire_fragment(:controller => :tags, :action => :index, :action_suffix => 'public_tag_cloud')
    when record.is_a?(BookmarkedResource)
      expire_editable_fragment(record.manifestation)
    when record.is_a?(Tag)
      record.tagged.each do |bookmark|
        expire_editable_fragment(bookmark.bookmarked_resource.manifestation)
      end
    when record.is_a?(Subject)
      expire_editable_fragment(record)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
      record.manifestations.each do |classification|
        expire_editable_fragment(classification)
      end
    when record.is_a?(Classification)
      expire_editable_fragment(record)
      record.subjects.each do |subject|
        expire_editable_fragment(subject)
      end
    #when record.is_a?(Concept)
    #  expire_fragment(:controller => :concepts, :action => :show, :id => record.id)
    #when record.is_a?(Place)
    #  expire_fragment(:controller => :places, :action => :show, :id => record.id)
    when record.is_a?(Create)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.work)
      record.work.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
    when record.is_a?(Realize)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.expression)
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
        manifestation.expressions.each do |expression|
          expire_editable_fragment(expression)
        end
      end
    when record.is_a?(Produce)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.manifestation)
      record.manifestation.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
    when record.is_a?(Own)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.item)
      expire_editable_fragment(record.item.manifestation)
    when record.is_a?(Reify)
      expire_editable_fragment(record.work)
      expire_editable_fragment(record.expression)
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(Embody)
      expire_editable_fragment(record.expression)
      expire_editable_fragment(record.manifestation)
      record.manifestation.expressions.each do |expression|
        expire_editable_fragment(expression)
      end
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(Exemplify)
      expire_editable_fragment(record.manifestation)
      expire_editable_fragment(record.item)
    when record.is_a?(Basket)
      record.items.each do |item|
        expire_editable_fragment(item)
        expire_manifestation_fragment(item.manifestation, 'show_holding')
      end
    when record.is_a?(Checkin)
      #expire_editable_fragment(record.item)
      #expire_editable_fragment(record.item.manifestation, "show_holding")
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_editable_fragment(record, fragments = nil)
    if record
      if record.is_a?(Manifestation)
        expire_manifestation_cache(record, fragments)
      else
        I18n.available_locales.each do |locale|
          expire_fragment(:controller => record.class.to_s.pluralize.downcase, :action => :show, :id => record.id, :editable => true, :locale => locale.to_s)
          expire_fragment(:controller => record.class.to_s.pluralize.downcase, :action => :show, :id => record.id, :editable => false, :locale => locale.to_s)
        end
      end
    end
  end

  def expire_manifestation_cache(manifestation, fragments)
    fragments = %w[detail_1 detail_2 detail_3 pickup index_list book_jacket show_index show_limited_authors show_all_authors show_editors_and_publishers show_holding tags title show_xisbn] if fragments.nil?
    expire_fragment(:controller => :manifestations, :action => :index, :action_suffix => 'numdocs')
    Array(fragments).each do |fragment|
      if manifestation
        expire_manifestation_fragment(manifestation, fragment)
      end
    end
    Rails.cache.delete("xisbn_#{manifestation.id}")
  end

  def expire_manifestation_fragment(manifestation, fragment)
    if manifestation
      I18n.available_locales.each do |locale|
        expire_fragment(:controller => :manifestations, :action => :show, :id => manifestation.id, :action_suffix => fragment, :editable => true, :locale => locale.to_s)
        expire_fragment(:controller => :manifestations, :action => :show, :id => manifestation.id, :action_suffix => fragment, :editable => false, :locale => locale.to_s)
      end
    end
  end
end
