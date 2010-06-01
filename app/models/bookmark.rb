# -*- encoding: utf-8 -*-
class Bookmark < ActiveRecord::Base
  named_scope :bookmarked, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  named_scope :user_bookmarks, lambda {|user| {:conditions => {:user_id => user.id}}}
  belongs_to :manifestation
  belongs_to :user #, :counter_cache => true, :validate => true

  validates_presence_of :user_id, :title, :url
  #validates_presence_of :url, :on => :create
  validates_associated :user, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :user_id
  validates_length_of :url, :maximum => 255, :allow_blank => true
  
  def self.per_page
    10
  end
  attr_accessor :local_url

  acts_as_taggable_on :tags

  searchable do
    text :title do
      manifestation.title
    end
    string :url do
      manifestation.access_address
    end
    string :tag, :multiple => true do
      tags.collect(&:name)
    end
    integer :user_id
    integer :manifestation_id
    time :created_at
    time :updated_at
  end

  def before_validation
    self.url = URI.parse(self.url).normalize.to_s
  rescue URI::InvalidURIError
    raise 'invalid_url'
  end

  def before_validation_on_create
    create_manifestation
  end

  def before_save
    # タグに含まれている全角スペースを除去する
    self.tag_list = self.tag_list.map{|tag| tag.gsub('　', ' ').gsub(' ', ', ')}
  end

  def after_create
    send_later(:create_frbr_object) unless url.my_host?
  end

  def after_save
    save_tagger
    expire_cache
    send_later(:save_manifestation)
  end

  def after_destroy
    expire_cache
    send_later(:save_manifestation)
  end

  def expire_cache
    Rails.cache.delete("Manifestation.search.total")
  end

  def save_manifestation
    self.manifestation.save
    self.manifestation.index!
  end

  def save_tagger
    #user.tag(self, :with => tag_list, :on => :tags)
    taggings.each do |tagging|
      tagging.tagger = user
      tagging.save(false)
      Tag.find(tagging.tag_id).index
    end
  end

  def shelved?
    true unless self.manifestation.items.on_web.empty?
  end

  def self.get_title(string)
    CGI.unescape(string).strip unless string.nil?
  end

  def get_title
    if url.my_host?
      my_host_resource.original_title
    else
      Bookmark.get_title_from_url(url)
    end
  end

  def self.get_title_from_url(url)
    return if url.blank?
    if url.my_host?
      path = URI.parse(url).path.split('/')
      if path[1] == 'manifestations' and Manifestation.find(path[2])
        manifestation = Manifestation.find(path[2])
        return manifestation.original_title
      end
    else
      doc = Nokogiri::HTML(open(url).read)
      # TODO: 日本語以外
      #charsets = ['iso-2022-jp', 'euc-jp', 'shift_jis', 'iso-8859-1']
      #if charsets.include?(page.charset.downcase)
        title = NKF.nkf('-w', CGI.unescapeHTML((doc.at("title").inner_text))).to_s.gsub(/\r\n|\r|\n/, '').gsub(/\s+/, ' ').strip
        if title.blank?
          title = url
        end
      #else
      #  title = (doc/"title").inner_text
      #end
      title
    end
  rescue OpenURI::HTTPError
    # TODO: 404などの場合の処理
    raise "unable to access: #{url}"
  #  nil
  end

  def self.get_canonical_url(url)
    doc = Nokogiri::HTML(open(url))
    canonical_url = doc.search("/html/head/link[@rel='canonical']").first['href']
    # TODO: URLを相対指定している時
    URI.parse(canonical_url).normalize.to_s
  rescue
    nil
  end

  def my_host_resource
    if url.my_host?
      path = URI.parse(url).path.split('/')
      if path[1] == 'manifestations' and Manifestation.find(path[2])
        manifestation = Manifestation.find(path[2])
      end
    else
      raise 'only_manifestation_should_be_bookmarked'
    end
  end

  def check_url
    # 自館のページをブックマークする場合
    if url.my_host?
      manifestation = self.my_host_resource
    else
      if LibraryGroup.site_config.allow_bookmark_external_url
        manifestation = Manifestation.first(:conditions => {:access_address => self.url}) if self.url.present?
      else
        # OTC start
#         manifestation = Manifestation.first(:conditions => {:access_address => self.url}) if self.url.present?
        # 自館のページではない場合
        raise 'not_our_holding'
        # OTC end
      end
    end
  end

  def create_manifestation
    manifestation = check_url
    unless manifestation
      manifestation = Manifestation.new(:access_address => url)
      manifestation.carrier_type = CarrierType.first(:conditions => {:name => 'file'})
    end
    # OTC start
    # check_urlで自館のmanifestation以外ならば例外とし登録させないよう修正した。
    # よって、unless文の処理は不要になるはず。
    # manifestation = check_urlを実行するのみ。nilの場合は上で処理するので処理不要。
#    manifestation = check_url
    # OTC end
    if manifestation.bookmarked?(user)
      raise 'already_bookmarked'
    end
    if self.title.present?
      manifestation.original_title = self.title
    else
      manifestation.original_title = self.get_title
    end
    self.manifestation = manifestation
  end

  def create_frbr_object
    unless url.my_host?
      Bookmark.transaction do
        work = Work.create!(:original_title => manifestation.original_title)
        expression = Expression.new(:original_title => work.original_title)
        work.expressions << expression
        manifestation.expressions << expression
        create_bookmark_item
      end
    end
  end

  def create_bookmark_item
    circulation_status = CirculationStatus.first(:conditions => {:name => 'Not Available'})
    item = Item.new(:shelf => Shelf.web, :circulation_status => circulation_status)
    self.manifestation.items << item
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    if manifestation
      self.bookmarked(start_date, end_date).count(:all, :conditions => {:manifestation_id => manifestation.id})
    else
      0
    end
  end

end
