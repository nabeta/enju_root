# -*- encoding: utf-8 -*-
class Bookmark < ActiveRecord::Base
  include LibrarianOwnerRequired

  named_scope :bookmarked, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  named_scope :user_bookmarks, lambda {|user| {:conditions => {:user_id => user.id}}}
  belongs_to :manifestation
  belongs_to :user #, :counter_cache => true, :validate => true
  validates_presence_of :user_id, :manifestation_id
  #validates_presence_of :url, :on => :create
  validates_associated :user, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :user_id
  validates_length_of :url, :maximum => 255, :allow_blank => true
  
  attr_accessor :url, :title
  cattr_accessor :per_page
  @@per_page = 10

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

  def after_save
    save_tagger
    save_manifestation
  end

  def before_validation_on_create
    create_bookmark
  end

  def after_destroy
    save_manifestation
  end

  def save_manifestation
    if self.manifestation
      self.manifestation.index
    end
  end

  def save_tagger
    #user.tag(self, :with => tag_list, :on => :tags)
    taggings.each do |tagging|
      tagging.tagger = user
      tagging.save(false)
    end
  end

  def shelved?
    true unless self.manifestation.items.on_web.empty?
  end

  def self.get_title(string)
    CGI.unescape(string).strip unless string.nil?
  end

  def self.get_title_from_url(url)
    return if url.blank?
    # TODO: ホスト名の扱い
    access_url = url.rewrite_my_url
  
    page = open(access_url)
    #doc = Hpricot(page)
    doc = Nokogiri(page)
    # TODO: 日本語以外
    #charsets = ['iso-2022-jp', 'euc-jp', 'shift_jis', 'iso-8859-1']
    #if charsets.include?(page.charset.downcase)
      title = NKF.nkf('-w', CGI.unescapeHTML((doc/"title").inner_text)).to_s.gsub(/\r\n|\r|\n/, '').gsub(/\s+/, ' ').strip
      if title.blank?
        title = url
      end
    #else
    #  title = (doc/"title").inner_text
    #end
    title
  rescue OpenURI::HTTPError
    # TODO: 404などの場合の処理
    raise "unable to access: #{access_url}"
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

  def check_url
    begin
      self.url = URI.parse(self.url).normalize.to_s
    rescue
      raise 'invalid_url'
    end

    # 自館のページをブックマークする場合
    if URI.parse(self.url).host == LIBRARY_WEB_HOSTNAME
      path = URI.parse(self.url).path.split('/')
      if path[1] == 'manifestations' and Manifestation.find(path[2])
        manifestation = Manifestation.find(path[2])
      end
    else
      manifestation = Manifestation.find(:first, :conditions => {:access_address => self.url}) if self.url.present?
    end
  end

  def create_bookmark
    manifestation = check_url
    if manifestation
      if manifestation.bookmarked?(user)
        raise 'already_bookmarked'
      end
    else
      manifestation = create_manifestation
    end

    self.manifestation = manifestation
    create_bookmark_item
  end

  def create_manifestation
    manifestation = Manifestation.new(:access_address => url)
    manifestation.carrier_type = CarrierType.find(:first, :conditions => {:name => 'file'})
    if self.title.present?
      manifestation.original_title = self.title
    else
      manifestation.original_title = Bookmark.get_title_from_url(url)
    end

    Bookmark.transaction do
      manifestation.save
      work = Work.create!(:original_title => manifestation.original_title)
      expression = Expression.new(:original_title => work.original_title)
      work.expressions << expression
      manifestation.expressions << expression
    end
    manifestation
  end

  def create_bookmark_item
    shelf = Shelf.web
    circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'Not Available'})
    item = Item.new
    item.circulation_status = circulation_status
    item.shelf = shelf
    self.manifestation.items << item
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    if manifestation
      self.bookmarked(start_date, end_date).count(:all, :conditions => {:manifestation_id => manifestation.id})
    else
      0
    end
  end

  def self.is_indexable_by(user, parent = nil)
    true if user.has_role?('User')
  rescue
    false
  end

  def is_readable_by(user, parent = nil)
    true if user.has_role?('Librarian')
  rescue
    false
  end

  #def is_updatable_by(user, parent = nil)
  #  true if user.has_role?('Librarian')
  #rescue
  #  false
  #end

  def is_deletable_by(user, parent = nil)
    true if user == self.user || user.has_role?('Librarian')
  rescue
    false
  end
end
