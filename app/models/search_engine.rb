class SearchEngine < ActiveRecord::Base
  acts_as_list
  belongs_to :library_group, :validate => true

  validates_presence_of :name, :url, :base_url, :query_param, :http_method
  validates_inclusion_of :http_method, :in => %w(get post)
  validates_length_of :url, :maximum => 255

  def validate
    errors.add(:url) unless (URI(read_attribute(:url)) rescue false)
    errors.add(:base_url) unless (URI(read_attribute(:base_url)) rescue false)
  end

  def search_params(query)
    params = {}
    if self.additional_param
      self.additional_param.gsub('{query}', query).to_s.split.each do |param|
        p = param.split("=")
        params[p[0]] = p[1]
      end
      return params
    end
  end

end
