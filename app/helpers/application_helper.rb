module ApplicationHelper
  def frbr_graph(resource)
    File.open("#{Rails.root.to_s}/public/#{resource.class.to_s.downcase.pluralize}/#{resource.id}.svg").read.html_safe if Setting.generate_graph
  rescue Errno::ENOENT
  end
end
