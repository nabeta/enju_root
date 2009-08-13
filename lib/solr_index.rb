module SolrIndex
  def save_with_index
    save
    index
  end

  def save_with_index!
    save
    index!
  end
end
