class Tag
  def subjects
    Manifestation.find_by_solr("tag: #{self.name}", :limit => taggings_count).results.collect(&:subjects).flatten
  end

  def self.bookmarked(manifestation_ids)
    BookmarkedResource.manifestations(manifestation_ids).collect(&:tags).flatten.uniq
  end

  def after_save
    #self.tagged.each do |b| b.bookmarked_resource.manifestation.save end
    self.tagged.each do |b| b.save end
  end

end
