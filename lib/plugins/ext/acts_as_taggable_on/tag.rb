class Tag < ActiveRecord::Base
  include OnlyLibrarianCanModify
  has_friendly_id :name

  searchable do
    text :name
    string :name
    time :created_at
    time :updated_at
    integer :bookmark_ids, :multiple => true do
      tagged(Bookmark).collect(&:id)
    end
    integer :taggings_count do
      taggings.size
    end
  end

  def self.per_page
    10
  end

  def self.bookmarked(bookmark_ids, options = {})
    unless bookmark_ids.empty?
      options = {:order => 'taggings_count DESC'}.merge(options)
      #tag_ids = Tag.search_ids do
      #  with(:bookmark_ids).any_of bookmark_ids
      #  paginate(:page => 1, :per_page => Tag.count)
      #end
      #Tag.all(:conditions => {:id => tag_ids}, :order => options[:order])
      tags = Tag.search do
        with(:bookmark_ids).any_of bookmark_ids
        order_by :taggings_count, :desc
        paginate(:page => 1, :per_page => Tag.count)
      end.results
    end
  end

  def after_save
    self.taggings.collect(&:taggable).each do |t| t.send_later(:save) end
  end

  def after_destroy
    after_save
  end

  def tagged(taggable_type)
    self.taggings.all(:conditions => {:taggable_type => taggable_type.to_s}).collect(&:taggable)
  end
end
