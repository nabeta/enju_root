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

  def self.parse(list)
    tag_names = []
    
    return tag_names if list.blank?
    
    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/) { tag_names << $1; "" }
    
    # 全角スペースを半角スペースに変換
    list.gsub!(/　/, " ")

    # then, replace all commas with a space
    list.gsub!(/,/, " ")

    # then, get whatever is left
    tag_names.concat(list.split(/\s/))
    
    # delete any blank tag names
    tag_names = tag_names.delete_if { |t| t.empty? }
    
    # downcase all tags
    tag_names = tag_names.map! { |t| t.downcase }
    
    # remove duplicates
    tag_names = tag_names.uniq
    
    return tag_names
  end
end

class Tagging
  validates_uniqueness_of :tag_id, :scope => [:taggable_type, :taggable_id]
end
