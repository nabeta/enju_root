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
  end

  def self.bookmarked(manifestation_ids)
    BookmarkedResource.manifestations(manifestation_ids).collect(&:tags).flatten.uniq
  end

  def after_save
    #self.tagged.each do |b| b.bookmarked_resource.manifestation.save end
    self.tagged.each do |b| b.save end
  end

  def tagged
    self.taggings.collect(&:taggable)
  end
end
