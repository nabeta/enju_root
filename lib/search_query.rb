module SearchQuery
  def add_query(object)
    case
    when object.is_a?(Patron)
      self.to_s + " patron_ids: #{object.id}"
    when object.is_a?(Work)
      self.to_s + " work_ids: #{object.id}"
    when object.is_a?(Expression)
      self.to_s + " expression_ids: #{object.id}"
    when object.is_a?(Manifestation)
      self.to_s + " manifestation_ids: #{object.id}"
    when object.is_a?(Subject)
      self.to_s + " subject_ids: #{object.id}"
    when object.is_a?(User)
      self.to_s + " user: #{object.login}"
    when object.is_a?(Library)
      self.to_s + " library: #{object.short_name}"
    when object.is_a?(Classification)
      self.to_s + " classification_ids: #{object.id}"
    when object.is_a?(SubjectHeadingType)
      self.to_s + " subject_heading_type_ids: #{object.id}"
    else
      self
    end
  end

  def add_query!(object)
    query = self.add_query(object)
    self.replace(query)
  end
end

class String
  include SearchQuery
end
