module DisplayName
  def display_name
    if self[:display_name].blank?
      self.name
    else
     self[:display_name]
    end
  end
end
