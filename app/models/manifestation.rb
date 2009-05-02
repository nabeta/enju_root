require 'open-uri'
require 'wakati'
require 'timeout'
class Manifestation < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  #include OnlyLibrarianCanModify
  include LibrarianOwnerRequired
  named_scope :pictures, :conditions => {:content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png']}
  has_many :embodies, :dependent => :destroy, :order => :position
  has_many :expressions, :through => :embodies, :order => 'embodies.position', :dependent => :destroy
  has_many :exemplifies, :dependent => :destroy
  has_many :items, :through => :exemplifies, :dependent => :destroy
  has_many :produces, :dependent => :destroy
  has_many :patrons, :through => :produces, :order => 'produces.position'
  has_one :manifestation_api_response, :dependent => :destroy
  has_many :reserves, :dependent => :destroy
  has_many :reserving_users, :through => :reserves, :source => :user
  belongs_to :manifestation_form #, :validate => true
  belongs_to :language, :validate => true
  has_one :attachment_file #, :dependent => :destroy
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  #has_many :orders, :dependent => :destroy
  has_one :bookmarked_resource, :dependent => :destroy
  has_many :resource_has_subjects, :as => :subjectable, :dependent => :destroy
  has_many :subjects, :through => :resource_has_subjects
  #has_many :children, :class_name => 'Manifestation', :foreign_key => :parent_id
  #belongs_to :parent, :class_name => 'Manifestation', :foreign_key => :parent_id
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :checkout_stat_has_manifestations
  has_many :checkout_stats, :through => :checkout_stat_has_manifestations
  has_many :bookmark_stat_has_manifestations
  has_many :bookmark_stats, :through => :bookmark_stat_has_manifestations
  has_many :reserve_stat_has_manifestations
  has_many :reserve_stats, :through => :reserve_stat_has_manifestations
  has_many :to_manifestations, :foreign_key => 'from_manifestation_id', :class_name => 'ManifestationHasManifestation', :dependent => :destroy
  has_many :from_manifestations, :foreign_key => 'to_manifestation_id', :class_name => 'ManifestationHasManifestation', :dependent => :destroy
  has_many :derived_manifestations, :through => :to_manifestations, :source => :manifestation_to_manifestation
  has_many :original_manifestations, :through => :from_manifestations, :source => :manifestation_from_manifestation
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :produces
  has_one :db_file

  acts_as_solr :fields => [{:created_at => :date}, {:updated_at => :date},
    :title, :author, :publisher, :access_address,
    {:isbn => :string}, {:isbn10 => :string}, {:wrong_isbn => :string},
    {:nbn => :string}, {:issn => :string}, {:tag => :string}, :fulltext,
    {:formtype => :string}, {:formtype_f => :facet},
    {:library => :string}, {:library_f => :facet},
    {:lang => :string}, {:language_f => :facet},
    :subject, :subject_f,
    :related_titles, :patron, {:shelf => :string},
    {:pubdate => :date}, {:number_of_pages => :range_integer},
    {:height => :range_float}, {:width => :range_float},
    {:depth => :range_float}, {:sortable_title => :string}, :note,
    {:volume_number => :range_integer}, {:issue_number => :range_integer},
    {:expression_ids => :integer}, {:patron_ids => :integer},
    {:subject_ids => :integer},
    {:serial_number => :range_integer},
    {:user => :string}, {:price => :range_float},
    {:required_role_id => :range_integer}, {:reservable => :boolean},
    ],
    :facets => [:formtype_f, :subject_f, :language_f, :library_f],
    #:if => proc{|manifestation| !manifestation.serial?},
    :offline => proc{|manifestation| manifestation.restrain_indexing},
    :auto_commit => false
  #acts_as_soft_deletable
  acts_as_tree
  enju_twitter
  enju_manifestation_viewer
  enju_amazon
  enju_porta
  enju_cinii
  #acts_as_taggable_on :subject_tags

  @@per_page = 10
  cattr_accessor :per_page
  attr_accessor :restrain_indexing

  validates_presence_of :original_title, :manifestation_form, :language
  validates_associated :manifestation_form, :language
  validates_numericality_of :start_page, :end_page, :allow_blank => true
  validates_length_of :access_address, :maximum => 255, :allow_blank => true

  def validate
    #unless self.date_of_publication.blank?
    #  date = Time.parse(self.date_of_publication.to_s) rescue nil
    #  errors.add(:date_of_publication) unless date
    #end

    unless self.isbn.blank?
      errors.add(:isbn) unless ISBN_Tools.is_valid?(self.isbn)
    end
  end

  def before_validation_on_create
    self.isbn = self.isbn.to_s.strip.gsub('-', '')
    if self.isbn.length == 10
      isbn10 = self.isbn.dup
      self.isbn = ISBN_Tools.isbn10_to_isbn13(self.isbn.to_s)
      self.isbn10 = isbn10
    end
  rescue
    nil
  end

  def after_save
    expire_cache
    send_later(:solr_commit)
    send_later(:generate_fragment_cache)
  end

  def after_destroy
    after_save
  end

  def expire_cache
    Rails.cache.delete("Manifestation:numdocs")
  end

  def self.cached_numdocs
    Rails.cache.fetch("Manifestation:numdocs"){Manifestation.numdocs}
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
    array.flatten.compact.sort.uniq
  end

  def titles
    title = []
    title << original_title
    title << title_transcription
    title << title_alternative
    title << original_title.wakati
    title << title_transcription.wakati rescue nil
    title << title_alternative.wakati rescue nil
    title
  end

  def available_checkout_types(user)
    user.user_group.user_group_has_checkout_types.available_for_manifestation_form(self.manifestation_form)
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
    self.expressions.serials.find(:first, :conditions => ['embodies.manifestation_id = ?', self.id])
  end

  def serial?
    return true if self.serial
    false
  end

  def next_reservation
    self.reserves.find(:first, :order => ['reserves.created_at'])
  end

  def authors
    patron_ids = []
    # 著編者
    (self.related_works.collect{|w| w.patrons}.flatten + self.expressions.collect{|e| e.patrons}.flatten).uniq
  end

  def author
    authors.collect(&:name).flatten
  end

  def editors
    patrons = []
    self.expressions.each do |expression|
      patrons += expression.patrons.uniq
    end
    patrons -= authors
  end

  def editor
    editors.collect(&:name).flatten
  end

  def publishers
    self.patrons
  end

  def publisher
    publishers.collect(&:name).flatten
  end

  def shelves
    self.items.collect{|item| item.shelves}.flatten.uniq
  end

  def tag
    #tags.collect{|t| Array(t.name) + t.synonym.to_s.split}.flatten
    tags.collect(&:name)
  end

  def tags
    if self.bookmarked_resource
      self.bookmarked_resource.bookmarks.collect{|bookmark| bookmark.tags}.flatten.uniq
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

  def sortable_title
    # 並べ替えの順番に使う項目を指定する
    # TODO: 読みが入力されていない資料
    self.title_transcription
  end

  def formtype
    self.manifestation_form.name
  end
  
  def formtype_f
    formtype
  end
  
  def subject
    subjects.collect(&:term) + subjects.collect(&:term_transcription)
  end

  def subject_f
    subjects.collect(&:term)
  end

  def library
    library_names = []
    self.items.each do |item|
      library_names << item.shelf.library.short_name
    end
    library_names.uniq
  end

  def library_f
    library
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

  def pubdate
    self.date_of_publication
  end

  def issn
    self.serial.issn if self.serial
  end

  def forms
    self.expressions.collect(&:expression_form).uniq
  end

  def languages
    self.expressions.collect(&:language).uniq
  end

  def lang
    languages.collect(&:name)
  end

  def language_f
    lang
  end

  def number_of_contents
    self.expressions.size - self.expressions.serials.size
  end

  def number_of_pages
    if self.start_page and self.end_page
      pages = self.end_page.to_i - self.start_page.to_i + 1
    end
  end

  def isbn13
    isbn
  end

  def self.find_by_isbn(isbn)
    if ISBN_Tools.is_valid?(isbn)
      manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn}, :include => :manifestation_form)
      if manifestation.nil?
        if isbn.length == 13
          isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
        else
          isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
        end
        manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn}, :include => :manifestation_form)
      end
    end
    return manifestation
  rescue
    nil
  end

  def expression_ids
    self.expressions.collect(&:id)
  end

  def patron_ids
    self.patrons.collect(&:id)
  end

  #def subjects
  #  self.works.collect(&:subjects).flatten
  #end

  def subject_ids
    self.subjects.collect(&:id)
  end

  def user
    if self.bookmarked_resource
      self.bookmarked_resource.bookmarks.collect(&:user).collect(&:login)
    else
      []
    end
  end

  def oai_identifier
    "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/#{self.id}"
  end

  def self.find_by_oai_identifier(oai_identifier)
    base_url = "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/"
    begin
      Manifestation.find(oai_identifier.gsub(base_url, '').to_i)
    rescue
      nil
    end
  end

  # TODO: ビューに移動する
  def to_oai_dc
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_dc:dc",
      'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
      'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation' =>
        %{http://www.openarchives.org/OAI/2.0/oai_dc/
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
        xml.tag!('oai_dc:title', original_title)
        xml.tag!('oai_dc:description', note)
        self.authors.each do |author|
          xml.tag!('oai_dc:creator', author.full_name)
        end
        self.languages.each do |language|
          xml.tag!('oai_dc:lang', language.name)
        end
        self.subjects.each do |subject|
          xml.tag!('oai_dc:subject', subject.term)
        end
    end
    xml.target!
  end

  def to_mods
    xml = Builder::XmlMarkup.new
    xml.mods('version' => '3.2'){
      xml.titleInfo{
        xml.title self.original_title
      }
      xml.name{
        self.authors.each do |author|
          xml.namePart author.full_name
        end
      }
    }
    xml.identifier("#{LibraryGroup.url}manifestations/#{self.id}", 'type' => 'uri')
    xml.originInfo{
      self.publishers.each do |publisher|
        xml.publisher publisher.full_name
      end
      xml.dateIssued self.date_of_publication.iso8601 if self.date_of_publication
    }
    xml.target!
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    resource = nil
    if keyword
      resources = self.find_id_by_solr(keyword, :limit => self.cached_numdocs)
      resource = self.find(resources.results[rand(resources.total_hits)]) rescue nil
    end
    if resource.blank?
      while resource.nil?
        resource = self.find(rand(self.cached_numdocs)) rescue nil
      end
    end
    return resource
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
        patron.restrain_indexing = true
        patron.required_role = Role.find(:first, :conditions => {:name => 'Guest'})
      end
      patron.save
      patrons << patron
    end
    return patrons
  end

  def set_serial_number(expression)
    if expression.serial? and expression.last_issue
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
  #    if self.bookmarked_resource
  #      self.bookmarked_resource.bookmarks
  #    else
  #      []
  #    end
  #  else
  #    Bookmark.bookmarked(start_date, end_date).find(:all, :conditions => {:bookmarked_resource_id => self.bookmarked_resource.id})
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

  def fulltext
    self.attachment_file.fulltext if self.attachment_file
  end

  def digest(options = {:type => 'sha1'})
    if self.file_hash.blank?
      self.file_hash = Digest::SHA1.hexdigest(self.db_file.data)
    end
    self.file_hash
  end

  def generate_fragment_cache
    url = "#{LibraryGroup.url}manifestations/#{id}"
    Net::HTTP.get(URI.parse(url))
    url = "#{LibraryGroup.url}manifestations/#{id}?mode=show_index"
    Net::HTTP.get(URI.parse(url))
    url = "#{LibraryGroup.url}manifestations/#{id}?mode=show_authors"
    Net::HTTP.get(URI.parse(url))
    url = "#{LibraryGroup.url}manifestations/#{id}?mode=pickup"
    Net::HTTP.get(URI.parse(url))
  end

end
