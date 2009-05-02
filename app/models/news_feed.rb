require 'rss'
class NewsFeed < ActiveRecord::Base
  include OnlyAdministratorCanModify

  default_scope :order => "position"
  belongs_to :library_group, :validate => true

  validates_presence_of :title, :url, :library_group
  validates_associated :library_group
  validates_length_of :url, :maximum => 255

  acts_as_list

  cattr_accessor :per_page
  @@per_page = 10

  def before_save
    self.body = nil
    expire_cache
  end

  def before_destroy
    expire_cache
  end

  def expire_cache
    Rails.cache.delete('NewsFeed.all')
  end

  def content
    url = self.url.rewrite_my_url
    if self.body.blank?
      feed = open(url).read
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

  def self.fetch_feeds
    require 'action_controller/integration'
    app = ActionController::Integration::Session.new
    app.host = LibraryGroup.url
    NewsFeed.find(:all).each do |news_feed|
      news_feed.force_reload
    end
    app.get("#{LibraryGroup.url}news_feeds?mode=clear_cache")
    logger.info "#{Time.zone.now} feeds reloaded!"
  rescue
    logger.info "#{Time.zone.now} reloading feeds failed!"
  end

end
