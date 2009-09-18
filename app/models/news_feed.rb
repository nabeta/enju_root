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

  def after_save
    body = nil
    expire_cache
  end

  def after_destroy
    expire_cache
  end

  def expire_cache
    Rails.cache.delete("news_feed_#{id}_content")
    Rails.cache.delete('NewsFeed.all')
  end

  def fetch_content
    begin
    #page_url = URI.parse(url.rewrite_my_url)
    #if page_url.port == 80
    #  if Feedbag.feed?(url)
    #    feed_url = url
    #  else
    #    feed_url = Feedbag.find(url).first
    #  end
    #else
      # auto-discovery 非対応
      feed_url = url
    #end
    #if self.body.blank?
      feed = open(feed_url.rewrite_my_url).read
      #if rss = RSS::Parser.parse(feed, false)
      #  self.update_attributes({:body => feed})
      #end
    #enda
    rescue StandardError, Timeout::Error
      nil
    end
    # tDiary の RSS をパースした際に to_s が空になる
    # rss = RSS::Parser.parse(feed)
    # rss.to_s
    # => ""
    #if rss.nil?
      begin
        rss = RSS::Parser.parse(feed)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(feed, false)
      rescue RSS::NotWellFormedError
        nil
      end
    #end
    #return rss
  end

  def content
    Rails.cache.fetch("news_feed_#{id}_content"){fetch_content}
  end

  def force_reload
    expire_cache
    content
  end

  def self.fetch_feeds
    require 'action_controller/integration'
    app = ActionController::Integration::Session.new
    app.host = LibraryGroup.url
    NewsFeed.find(:all).each do |news_feed|
      news_feed.force_reload
      app.get("#{LibraryGroup.url}news_feeds/#{news_feed.id}", :mode => 'force_reload')
    end
    logger.info "#{Time.zone.now} feeds reloaded!"
  rescue
    logger.info "#{Time.zone.now} reloading feeds failed!"
  end
end
