module SuggestTag
  def suggest_tags
    tags = []
    threshold = (self.strip.split(//).size * 0.2).round
    Tag.find(:all, :order => 'taggings_count DESC', :limit => 100).each do |t|
      distance = Text::Levenshtein.distance(t.name, self)
      tags << t if distance <= threshold
    end
    tags
  rescue
    []
  end
end

class String
  include SuggestTag
end
