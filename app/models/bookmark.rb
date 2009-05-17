class Bookmark < ActiveRecord::Base
  include LibrarianOwnerRequired

  named_scope :bookmarked, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  named_scope :user_bookmarks, lambda {|user| {:conditions => {:user_id => user.id}}}
  belongs_to :bookmarked_resource, :counter_cache => true #, :validate => true
  belongs_to :user #, :counter_cache => true, :validate => true
  validates_presence_of :user, :bookmarked_resource_id, :title
  validates_presence_of :url, :on => :create
  validates_associated :user, :bookmarked_resource
  validates_uniqueness_of :bookmarked_resource_id, :scope => :user_id
  validates_length_of :url, :maximum => 255, :allow_blank => true
  
  cattr_accessor :per_page
  attr_accessor :url, :title
  @@per_page = 10

  acts_as_taggable_on :tags

  def after_save
    if self.bookmarked_resource
      self.bookmarked_resource.send_later(:reload)
      self.bookmarked_resource.send_later(:save)
    end
  end

  def after_destroy
    after_save
  end

  #def title
  #  self.bookmarked_resource.title
  #end

  #def url
  #  self.bookmarked_resource.url
  #end

  def shelved?
    true unless self.bookmarked_resource.manifestation.items.on_web.empty?
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

  def create_bookmark_item
    shelf = Shelf.web
    circulation_status = CirculationStatus.find(:first, :conditions => {:name => 'Not Available'})
    item = Item.new
    item.circulation_status = circulation_status
    item.shelf = shelf
    self.bookmarked_resource.manifestation.items << item
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    if manifestation.bookmarked_resource
      self.bookmarked(start_date, end_date).count(:all, :conditions => {:bookmarked_resource_id => manifestation.bookmarked_resource.id})
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
