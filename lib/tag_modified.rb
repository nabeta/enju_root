class Tag < ActiveRecord::Base
  include OnlyLibrarianCanModify
  has_friendly_id :name

  @@per_page = 10
  cattr_accessor :per_page

  searchable :auto_index => false do
    text :name
    string :name
    time :created_at
    time :updated_at
    integer :bookmark_ids, :multiple => true do
      tagged.collect(&:id)
    end
  end

  def self.bookmarked(bookmark_ids)
    tag_ids = Tag.search_ids do
      with(:bookmark_ids).any_of bookmark_ids
    end
    Tag.find(:all, :conditions => {:id => tag_ids})
  end

  def after_save
    #self.tagged.each do |b| b.bookmarked_resource.manifestation.save end
    self.tagged.each do |b| b.save end
  end

  def tagged
    self.taggings.collect(&:taggable)
  end
end
