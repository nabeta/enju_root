require 'wakati'
require 'timeout'
class Manifestation < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  #include OnlyLibrarianCanModify
  include LibrarianOwnerRequired
  include SolrIndex
  #named_scope :pictures, :conditions => {:content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png']}
  named_scope :pictures, :conditions => {:attachment_content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png']}
  named_scope :serials, :conditions => ['frequency_id > 1']
  named_scope :not_serials, :conditions => ['frequency_id = 1']
  has_many :embodies, :dependent => :destroy, :order => :position
  has_many :expressions, :through => :embodies, :order => 'embodies.position', :dependent => :destroy
  has_many :exemplifies, :dependent => :destroy
  has_many :items, :through => :exemplifies, :dependent => :destroy
  has_many :produces, :dependent => :destroy
  has_many :patrons, :through => :produces, :order => 'produces.position'
  #has_one :manifestation_api_response, :dependent => :destroy
  has_many :reserves, :dependent => :destroy
  has_many :reserving_users, :through => :reserves, :source => :user
  belongs_to :carrier_type #, :validate => true
  belongs_to :extent #, :validate => true
  belongs_to :language, :validate => true
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  #has_many :orders, :dependent => :destroy
  #has_many :work_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :work_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :checkout_stat_has_manifestations
  has_many :checkout_stats, :through => :checkout_stat_has_manifestations
  has_many :bookmark_stat_has_manifestations
  has_many :bookmark_stats, :through => :bookmark_stat_has_manifestations
  has_many :reserve_stat_has_manifestations
  has_many :reserve_stats, :through => :reserve_stat_has_manifestations
  has_many :to_manifestations, :foreign_key => 'from_manifestation_id', :class_name => 'ManifestationHasManifestation', :dependent => :destroy
  has_many :from_manifestations, :foreign_key => 'to_manifestation_id', :class_name => 'ManifestationHasManifestation', :dependent => :destroy
  has_many :derived_manifestations, :through => :to_manifestations, :source => :to_manifestation
  has_many :original_manifestations, :through => :from_manifestations, :source => :from_manifestation
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :produces
  belongs_to :frequency #, :validate => true
  has_many :subscribes, :dependent => :destroy
  has_many :subscriptions, :through => :subscribes
  has_many :bookmarks
  has_many :users, :through => :bookmarks
  belongs_to :nii_type

  searchable do
    text :title, :fulltext, :note, :author, :editor, :publisher, :subject
    text :tag do
      tags.collect(&:name)
    end
    string :isbn, :multiple => true do
      [isbn, isbn10, wrong_isbn]
    end
    string :issn
    string :lccn
    string :nbn
    string :tag, :multiple => true do
      tags.collect(&:name)
    end
    string :carrier_type do
      carrier_type.name
    end
    string :library, :multiple => true
    string :language, :multiple => true do
      languages.collect(&:name)
    end
    string :shelf, :multiple => true
    string :user, :multiple => true
    string :subject, :multiple => true
    integer :subject_ids, :multiple => true do
      self.subjects.collect(&:id)
    end
    string :sort_title
    time :created_at
    time :updated_at
    time :date_of_publication
    integer :patron_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_manifestation_ids, :multiple => true
    integer :derived_manifestation_ids, :multiple => true
    integer :expression_ids, :multiple => true
    integer :subscription_ids, :multiple => true
    integer :required_role_id
    integer :carrier_type_id
    integer :height
    integer :width
    integer :depth
    integer :volume_number, :multiple => true
    integer :issue_number, :multiple => true
    integer :serial_number, :multiple => true
    integer :start_page
    integer :end_page
    integer :number_of_pages
    float :price
    boolean :reservable
    boolean :subscription_master
  end

  #acts_as_tree
  enju_twitter
  enju_manifestation_viewer
  enju_amazon
  enju_porta
  enju_cinii
  has_attached_file :attachment
  has_ipaper_and_uses 'Paperclip'
  enju_scribd
  enju_mozshot
  enju_oai_pmh
  enju_worldcat

  @@per_page = 10
  cattr_accessor :per_page

  validates_presence_of :original_title, :carrier_type, :language
  validates_associated :carrier_type, :language
  validates_numericality_of :start_page, :end_page, :allow_blank => true
  validates_length_of :access_address, :maximum => 255, :allow_blank => true
  validates_uniqueness_of :isbn, :allow_blank => true
  validates_uniqueness_of :nbn, :allow_blank => true
  validates_format_of :access_address, :with => URI::regexp(%w(http https)) , :allow_blank => true

  def validate
    #unless self.date_of_publication.blank?
    #  date = Time.parse(self.date_of_publication.to_s) rescue nil
    #  errors.add(:date_of_publication) unless date
    #end

    if self.isbn.present?
      errors.add(:isbn) unless ISBN_Tools.is_valid?(self.isbn)
    end
  end

  def before_validation_on_create
    ISBN_Tools.cleanup!(self.isbn)
    if self.isbn.length == 10
      isbn10 = self.isbn.dup
      self.isbn = ISBN_Tools.isbn10_to_isbn13(self.isbn.to_s)
      self.isbn10 = isbn10
    end
  rescue
    nil
  end

  def before_validation_on_update
    ISBN_Tools.cleanup!(self.isbn) if self.isbn.present?
  end

  def after_create
    send_later(:set_digest) if self.attachment.path
    Rails.cache.delete("Manifestation.search.total")
  end

  def after_save
    send_later(:expire_cache)
    send_later(:generate_fragment_cache)
  end

  def after_destroy
    Rails.cache.delete("Manifestation.search.total")
    send_later(:expire_cache)
  end

  def expire_cache
    sleep 5
    Rails.cache.delete("worldcat_record_#{id}")
    Rails.cache.delete("xisbn_manifestations_#{id}")
    Rails.cache.fetch("manifestation_screen_shot_#{id}")
  end

  def self.cached_numdocs
    Rails.cache.fetch("Manifestation.search.total"){Manifestation.search.total}
  end

  def full_title
    # TODO: 号数
    original_title + " " + volume_number.to_s
  end

  def title
    array = self.titles
    self.expressions.each do |expression|
      array << expression.titles
      if expression.work
        array << expression.work.title
      end
    end
    #array << worldcat_record[:title] if worldcat_record
    array.flatten.compact.sort.uniq
  end

  def titles
    title = []
    title << original_title
    title << title_transcription
    title << title_alternative
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title
  end

  def url
    #access_address
    "#{LibraryGroup.url}manifestations/#{self.id}"
  end

  def available_checkout_types(user)
    user.user_group.user_group_has_checkout_types.available_for_carrier_type(self.carrier_type)
  end

  def checkout_period(user)
    available_checkout_types(user).collect(&:checkout_period).max
  end
  
  def reservation_expired_period(user)
    available_checkout_types(user).collect(&:reservation_expired_period).max
  end
  
  def embodies?(expression)
    expression.manifestations.detect{|manifestation| manifestation == self}
  end

  def serial
    false
  #  self.expressions.serials.find(:first, :conditions => ['embodies.manifestation_id = ?', self.id])
  end

  def serial?
    true if subscription_master
  end

  def serials
    []
  end

  def next_reservation
    self.reserves.find(:first, :order => ['reserves.created_at'])
  end

  def authors
    patron_ids = []
    # 著編者
    (self.related_works.collect{|w| w.patrons}.flatten + self.expressions.collect{|e| e.patrons}.flatten).uniq
  end

  def editors
    patrons = []
    self.expressions.each do |expression|
      patrons += expression.patrons.uniq
    end
    patrons -= authors
  end

  def publishers
    self.patrons
  end

  def shelves
    self.items.collect{|item| item.shelves}.flatten.uniq
  end

  def tags
    unless self.bookmarks.empty?
      self.bookmarks.collect{|bookmark| bookmark.tags}.flatten.uniq
    else
      []
    end
  end

  def works
    self.expressions.collect{|e| e.work}.uniq.compact
  end

  def patron
    self.patrons.collect(&:name) + self.expressions.collect{|e| e.patrons.collect(&:name) + e.work.patrons.collect(&:name)}.flatten
  rescue
    []
  end

  def shelf
    self.items.collect{|i| i.shelf.library.name + i.shelf.name}
  end

  def related_root_works
    works = []
    self.expressions.each do |expression|
      works << expression.work.root
      #works << e.work.parent
      #works << e.work.children
    end
    return works.uniq
  end

  def related_works(options = {:include_ancestors => false})
    works = []
    if options[:include_ancestors]
      works = (self.works + self.works.collect{|w| w.ancestors}.flatten).uniq
    else
      works = self.works
    end

    if self.serial
      works - Array([self.serial.work])
    else
      works.compact
    end
  rescue
    []
  end

  def related_titles
    (related_works(:include_ancestors => true).collect(&:title) + related_works(:include_ancestors => true).collect(&:title_transcription) + self.expressions.collect(&:title) + self.expressions.collect(&:title_transcription) + related_manifestations.collect(&:title) + related_manifestations.collect(&:title_transcription)).uniq
  rescue
    []
  end
  
  def related_manifestations
    serials = self.expressions.serials.collect(&:manifestations)
    manifestations = self.works.collect{|w| w.expressions.collect{|e| e.manifestations}}.flatten.uniq.compact - serials - Array(self)
  rescue
    []
  end

  def sort_title
    # 並べ替えの順番に使う項目を指定する
    # TODO: 読みが入力されていない資料
    self.title_transcription
  end

  def subjects
    works.collect(&:subjects).flatten
  end
  
  def library
    library_names = []
    self.items.each do |item|
      library_names << item.shelf.library.name
    end
    library_names.uniq
  end

  def volume_number
    volume_number_list.gsub(/\D/, ' ').split(" ") if volume_number_list
  end

  def issue_number
    issue_number_list.gsub(/\D/, ' ').split(" ") if issue_number_list
  end

  def serial_number
    serial_number_list.gsub(/\D/, ' ').split(" ") if serial_number_list
  end

  def forms
    self.expressions.collect(&:content_type).uniq
  end

  def languages
    self.expressions.collect(&:language).uniq
  end

  def number_of_contents
    self.expressions.size - self.expressions.serials.size
  end

  def number_of_pages
    if self.start_page and self.end_page
      page = self.end_page.to_i - self.start_page.to_i + 1
    end
  end

  def publisher
    publishers.collect(&:name).flatten
  end

  def author
    authors.collect(&:name).flatten
  end

  def editor
    editors.collect(&:name).flatten
  end

  def subject
    subjects.collect(&:term) + subjects.collect(&:term_transcription)
  end

  def isbn13
    isbn
  end

  def self.find_by_isbn(isbn)
    if ISBN_Tools.is_valid?(isbn)
      ISBN_Tools.cleanup!(isbn)
      manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn})
      if manifestation.nil?
        if isbn.length == 13
          isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
        else
          isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        end
        manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn})
      end
    end
    return manifestation
  rescue
    nil
  end

  def subjects
    self.works.collect(&:subjects).flatten
  end

  def user
    if self.bookmarks
      self.bookmarks.collect(&:user).collect(&:login)
    else
      []
    end
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    resource = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Sunspot.search(Manifestation) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    resource = response.results.first
    #if resource.nil?
    #  while resource.nil?
    #    resource = self.find(rand(self.cached_numdocs) + 1) rescue nil
    #  end
    #end
    #return resource
  end

  def subscribed?
    self.expressions.each do |expression|
      return true if expression.subscribed?
    end
  end

  def self.import_patrons(patron_lists)
    patrons = []
    patron_lists.each do |patron_list|
      unless patron = Patron.find(:first, :conditions => {:full_name => patron_list})
        patron = Patron.new(:full_name => patron_list, :language_id => 1)
        patron.required_role = Role.find(:first, :conditions => {:name => 'Guest'})
      end
      patron.save
      patrons << patron
    end
    return patrons
  end

  def set_serial_number(expression)
    if self.serial? and self.last_issue
      unless expression.last_issue.serial_number_list.blank?
        self.serial_number_list = expression.last_issue.serial_number_list.to_i + 1
        unless expression.last_issue.issue_number_list.blank?
          self.issue_number_list = expression.last_issue.issue_number_list.split.last.to_i + 1
        else
          self.issue_number_list = expression.last_issue.issue_number_list
        end
        self.volume_number_list = expression.last_issue.volume_number_list
      else
        unless expression.last_issue.issue_number_list.blank?
          self.issue_number_list = expression.last_issue.issue_number_list.split.last.to_i + 1
          self.volume_number_list = expression.last_issue.volume_number_list
        else
          unless expression.last_issue.volume_number_list.blank?
            self.volume_number_list = expression.last_issue.volume_number_list.split.last.to_i + 1
          end
        end
      end
    end
  end

  def is_reserved_by(user = nil)
    if user
      return true if Reserve.waiting.find(:first, :conditions => {:user_id => user.id, :manifestation_id => self.id})
    else
      return true if self.reserves.present?
    end
    false
  end

  def reservable
    return false if self.items.not_for_checkout.present?
    true
  end

  def checkouts(start_date, end_date)
    Checkout.completed(start_date, end_date).find(:all, :conditions => {:item_id => self.items.collect(&:id)})
  end

  #def bookmarks(start_date = nil, end_date = nil)
  #  if start_date.blank? and end_date.blank?
  #    if self.bookmarks
  #      self.bookmarks
  #    else
  #      []
  #    end
  #  else
  #    Bookmark.bookmarked(start_date, end_date).find(:all, :conditions => {:manifestation_id => self.id})
  #  end
  #end

  def fetch_expression_feed
    if self.serial?
      begin
        rss = RSS::Parser.parse(self.serial.feed_url)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(self.serial.feed_url, false)
      end

      # 出版日を調べる
      /\[(.*?)\]/ =~ rss.items.first.description
      if self.date_of_publication == Time.zone.parse($1)
        rss.items.each do |item|
          manifestation = Manifestation.find(:first, :conditions => {:access_address => item.link})
          if manifestation.blank?
            Manifestation.transaction do
              work = Work.create(:original_title => item.title)
              expression = Expression.new(:original_title => item.title)
              work.expressions << expression
              manifestation = Manifestation.new(:original_title => item.title, :access_address => item.link)
              expression.manifestations << manifestation
              self.expressions << expression
            end
          end
        end
      end
    end
  rescue
    nil
  end

  def set_digest(options = {:type => 'sha1'})
    file_hash = Digest::SHA1.hexdigest(File.open(self.attachment.path, 'rb').read)
    save(false)
  end

  def generate_fragment_cache
    sleep 5
    url = "#{LibraryGroup.url}manifestations/#{id}?mode=generate_cache"
    Net::HTTP.get(URI.parse(url))
  end

  def extract_text
    extractor = ExtractContent::Extractor.new
    text = Tempfile::new("text")
    case self.attachment_content_type
    when "application/pdf"
      system("pdftotext -q -enc UTF-8 -raw #{attachment(:path)} #{text.path}")
      self.fulltext = text.read
    when "application/msword"
      system("antiword #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = text.read
    when "application/vnd.ms-excel"
      system("xlhtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "application/vnd.ms-powerpoint"
      system("ppthtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "text/html"
      # TODO: 日本語以外
      system("elinks --dump 1 #{attachment(:path)} 2> /dev/null | nkf -w > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    end

    #self.indexed_at = Time.zone.now
    self.save(false)
    text.close
  end

  def derived_manifestations_by_solr(options = {})
    page = options[:page] || 1
    sort_by = options[:sort_by] || 'created_at'
    order = options[:order] || 'desc'
    search = Sunspot.new_search(Manifestation)
    search.build do
      with(:original_manifestation_ids).equal_to self.id
      order_by(:sort_by, order)
    end
    search.query.paginate page.to_i, Manifestation.per_page
    search.execute!.results
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def bookmarks_count
    self.bookmarks.size
  end

  def produced(patron)
    produces.find(:first, :conditions => {:id => patron.id})
  end

  def embodied(expression)
    embodies.find(:first, :conditions => {:id => expression.id})
  end

end
