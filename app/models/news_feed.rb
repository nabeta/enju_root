require 'rss'
class NewsFeed < ActiveRecord::Base
  belongs_to :library_group, :validate => true

  validates_presence_of :title, :url, :library_group
  validates_associated :library_group
  validates_length_of :url, :maximum => 255

  acts_as_list

  def content
    if self.body.blank?
      file = open(self.url)
      feed = file.read
      if rss = RSS::Parser.parse(feed, false)
        self.update_attributes({:body => feed})
      end
    end
    # tDiary の RSS をパースした際に to_s が空になる
    # rss = RSS::Parser.parse(self.url)
    # rss.to_s
    # => ""
    if rss.nil?
      begin
        rss = RSS::Parser.parse(self.body)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(self.body, false)
      end
    end
    return rss
  rescue
    nil
  end

  def force_reload
    self.update_attributes({:body => nil})
    content
  end

end
