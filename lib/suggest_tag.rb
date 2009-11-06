module SuggestTag
  def suggest_tags
    tags = []
    Tag.find(:all, :order => 'taggings_count DESC', :limit => 100).each do |t|
      distance = Text::Levenshtein.distance(t.name, self)
      tags << t if distance <= 1
    end
    tags
  rescue
    []
  end
end

class String
  include SuggestTag
end
