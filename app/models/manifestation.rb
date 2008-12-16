require 'open-uri'
require 'wakati'
class Manifestation < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  has_many :embodies, :dependent => :destroy, :order => :position
  has_many :expressions, :through => :embodies, :conditions => 'expressions.deleted_at IS NULL', :order => 'embodies.position', :dependent => :destroy, :include => [:expression_form, :language]
  has_many :exemplifies, :dependent => :destroy
  has_many :items, :through => :exemplifies, :include => [:checkouts, :shelf, :circulation_status], :dependent => :destroy, :conditions => 'items.deleted_at IS NULL'
  has_many :produces, :dependent => :destroy
  has_many :patrons, :through => :produces, :conditions => "patrons.deleted_at IS NULL", :order => 'produces.position', :include => :patron_type
  has_one :manifestation_api_response, :dependent => :destroy
  has_many :reserves, :dependent => :destroy, :conditions => 'reserves.deleted_at IS NULL'
  has_many :reserving_users, :through => :reserves, :source => :user, :conditions => 'users.deleted_at IS NULL'
  belongs_to :manifestation_form #, :validate => true
  belongs_to :language, :validate => true
  has_many :attachment_files, :as => :attachable, :dependent => :destroy
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  #has_many :orders, :conditions => 'orders.deleted_at IS NULL', :dependent => :destroy
  has_one :bookmarked_resource, :dependent => :destroy, :include => :bookmarks
  has_many :resource_has_subjects, :as => :subjectable, :dependent => :destroy
  has_many :subjects, :through => :resource_has_subjects
  #has_many :children, :class_name => 'Manifestation', :foreign_key => :parent_id
  #belongs_to :parent, :class_name => 'Manifestation', :foreign_key => :parent_id
  belongs_to :access_role, :class_name => 'Role', :foreign_key => 'access_role_id', :validate => true
  has_many :manifestation_checkout_stat_has_manifestations
  has_many :checkout_stats, :through => :manifestation_checkout_stat_has_manifestations
  has_many :bookmark_stat_has_manifestations
  has_many :bookmark_stats, :through => :bookmark_stat_has_manifestations
  has_many :reserve_stat_has_manifestations
  has_many :reserve_stats, :through => :reserve_stat_has_manifestations
  
  acts_as_solr :fields => [{:created_at => :date}, {:updated_at => :date},
    :title, :author, :publisher,
    {:isbn => :string}, {:isbn10 => :string}, {:wrong_isbn => :string},
    {:nbn => :string}, {:issn => :string}, {:tag => :string}, #:fulltext,
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
    {:access_role_id => :range_integer}
    ],
    :facets => [:formtype_f, :subject_f, :language_f, :library_f],
    #:if => proc{|manifestation| manifestation.deleted_at.blank? and !manifestation.serial?},
    :if => proc{|manifestation| manifestation.deleted_at.blank?},
    :auto_commit => false
  acts_as_taggable
  acts_as_paranoid
  acts_as_tree

  @@per_page = 10
  cattr_reader :per_page
  cattr_reader :result_limit

  validates_presence_of :original_title, :manifestation_form, :language
  validates_associated :manifestation_form, :language
  #validates_format_of :isbn, :with => /\A[\d]{9,12}[\dX]\Z/, :if => proc{|manifestation| !manifestation.isbn.blank?}
  #validates_length_of :isbn, :minimum => 10, :if => proc{|manifestation| !manifestation.isbn.blank?}
  #validates_length_of :isbn, :maximum => 13, :if => proc{|manifestation| !manifestation.isbn.blank?}
  validates_numericality_of :start_page, :end_page, :allow_nil => true
  validates_length_of :access_address, :maximum => 255, :allow_nil => true

  #after_create :post_to_twitter

  def validate
    unless self.date_of_publication.blank?
      date = Time.parse(self.date_of_publication.to_s) rescue nil
      errors.add(:date_of_publication) unless date
    end

    unless self.isbn.blank?
      errors.add(:isbn) unless ISBN_Tools.is_valid?(self.isbn)
    end
  end

  def before_validation_on_create
    if self.isbn.length == 10
      self.isbn = ISBN_Tools.isbn10_to_isbn13(self.isbn.to_s)
      self.isbn10 = self.isbn
    end
  rescue
    nil
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
  
  def reserved?(user = nil)
    if user
      self.reserving_users.collect{|r|
        return true if  r.id == user.id
      }
    else
      return true unless self.reserves.blank?
    end
    return false
  end

  def embodies?(expression)
    expression.manifestations.detect{|manifestation| manifestation == self} rescue nil
  end

  def serial
    self.expressions.serials.find(:first, :conditions => ['embodies.manifestation_id = ?', self.id])
  end

  def serial?
    return true if self.serial
    false
  end

  def item_checkouts_count
    count = 0
    self.items.each do |item|
      count += item.checkouts.size
    end
    return count
  end

  def self.item_checkouts_count
    count = 0
    #self.find(:all, :include => :items, :conditions => ['items.checkouts_count > 0']).each do |manifestation|
    self.find(:all).each do |manifestation|
      count += manifestation.item_checkouts_count
    end
    return count
  end

  def next_reservation
    self.reserves.find(:first, :order => ['reserves.created_at'])
  end

  def youtube_id
    if access_address
      url = URI.parse(access_address)
      if url.host =~ /youtube\.com$/ and url.path == "/watch"
        return CGI.parse(url.query)["v"][0]
      end
    end
  end

  def nicovideo_id
    if access_address
      url = URI.parse(access_address)
      if url.host =~ /nicovideo\.jp$/ and url.path =~ /^\/watch/
        return url.path.split("/")[2]
      end
    end
  end

  def authors
    self.reload
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

  def items_on_shelves
    items = []
    self.items.each do |item|
      items << item unless item.shelf.web_shelf?
    end
    items
  end

  def tag
    tags.collect{|t| Array(t.name) + t.synonym.to_s.split}
  end

  def tags
    self.bookmarks.collect{|bookmark| bookmark.tags}.flatten.uniq
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
    serials = self.expressions.find(:all, :select => ['expressions.id'], :conditions => ['frequency_of_issue_id > 1']).collect{|e| e.manifestations}.flatten.uniq.compact
    manifestations = self.works.collect{|w| w.expressions.collect{|e| e.manifestations}}.flatten.uniq.compact - serials - Array(self)
  rescue
    []
  end

  def fulltext
    fulltext = ""
    self.attachment_files.each do |file|
      fulltext += file.fulltext.to_s
    end
    return fulltext
  end

  def sortable_title
    # 並べ替えの順番に使う項目を指定する
    self.title_transcription
  end

  def formtype
    self.manifestation_form.name rescue nil
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
    forms = []
    self.expressions.each do |expression|
      forms << expression.expression_form
    end
    forms.uniq!
  end

  def languages
    languages = []
    self.expressions.each do |expression|
      languages << expression.language
    end
    languages.uniq
  end

  def lang
    languages.collect(&:name)
  end

  def language_f
    lang
  end

  def number_of_contents
    self.expressions.size - self.expressions.find(:all, :conditions => ['frequency_of_issue_id > 1']).size
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

  def subject_ids
    self.subjects.collect(&:id)
  end

  def user
    user_login_names = []
    self.bookmarks.each do |bookmark|
      user_login_names << bookmark.user.login #if bookmark.user.share_bookmarks
    end
    return user_login_names
  end

  def oai_identifier
    "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/#{self.id}"
  end

  def self.find_by_oai_identifier(oai_identifier)
    base_url = "oai:#{LIBRARY_WEB_HOSTNAME}/manifestations/"
    begin
      id = oai_identifier.gsub(base_url, '').to_i
      resource = Manifestation.find(id)
    rescue
      nil
    end
  end

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
        subjects.each do |subject|
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
    xml.identifier("http://#{LIBRARY_WEB_HOSTNAME}/manifestations/#{self.id}", 'type' => 'uri')
    xml.originInfo{
      self.publishers.each do |publisher|
        xml.publisher publisher.full_name
      end
      xml.dateIssued self.date_of_publication.iso8601 if self.date_of_publication
    }
    xml.target!
  end

  # TODO: 投稿は非同期で行う
  def post_to_twitter
    library_group = LibraryGroup.find(1)
    if Twitter::Status
      title = ERB::Util.html_escape(truncate(self.original_title))
      status = "#{library_group.name}: #{full_title} http://#{LIBRARY_WEB_HOSTNAME}/manifestations/#{self.id}"
      Twitter::Status.post(:update, :status => status)
    end
  end

  def access_amazon
    # キャッシュがない場合
    if self.manifestation_api_response.blank?
      amazon_url = ""
      #@isbn = @resource.searchable.isbn.sub("urn:isbn:", "") rescue ""
      unless self.isbn.blank?
        #@amazon_url = "http://#{@library_group.amazon_host}/onca/xml?Service=AWSECommerceService&SubscriptionId=#{AMAZON_ACCESS_KEY}&Operation=ItemLookup&IdType=ASIN&ItemId=#{@resource.searchable.isbn}&ResponseGroup=Images"
        amazon_url = "https://#{AMAZON_AWS_HOSTNAME}/onca/xml?Service=AWSECommerceService&SubscriptionId=#{AMAZON_ACCESS_KEY}&Operation=ItemLookup&SearchIndex=Books&IdType=ISBN&ItemId=#{isbn}&ResponseGroup=Images,Reviews"
        last_response = AawsResponse.find(:first, :order => 'created_at DESC')
        unless last_response.nil?
          # 1 request per 1 second
          i = 0
          while Time.zone.now - last_response.created_at <= 1
            sleep 1 - (Time.zone.now - last_response.created_at)
            i += 1
            if i > 10
              raise "timeout"
            end
          end
        end

        # Get XML response file from Amazon Web Service
        doc = nil
        open(amazon_url){|f|
          doc = REXML::Document.new(f)
        }
        # Save XML response file
        if self.manifestation_api_response
          self.manifestation_api_response.update_attributes({:body => doc.to_s})
        else
          xmlfile = AawsResponse.new(:body => doc.to_s)
          self.manifestation_api_response = xmlfile
          self.manifestation_api_response.save
        end
      else
        raise "no isbn"
      end
    end
  end
    
  def amazon_book_jacket
    access_amazon
    self.reload
    doc = REXML::Document.new(self.manifestation_api_response.body)
    r = Array.new
    r = REXML::XPath.match(doc, '/ItemLookupResponse/Items/Item/')
    bookjacket = {}
    bookjacket['url'] = REXML::XPath.first(r[0], 'MediumImage/URL/text()').to_s
    bookjacket['width'] = REXML::XPath.first(r[0], 'MediumImage/Width/text()').to_s.to_i
    bookjacket['height'] = REXML::XPath.first(r[0], 'MediumImage/Height/text()').to_s.to_i
    bookjacket['asin'] = REXML::XPath.first(r[0], 'ASIN/text()').to_s

    if bookjacket['url'].blank?
      raise "Can't get bookjacket"
    end
    return bookjacket

  rescue
    bookjacket = {'url' => 'unknown_resource.png', 'width' => '100', 'height' => '100'}
  end

  def amazon_customer_review
    reviews = []
    doc = REXML::Document.new(self.manifestation_api_response.body)
    reviews = []
    doc.elements.each('/ItemLookupResponse/Items/Item/CustomerReviews/Review') do |item|
      reviews << item
    end

    comments = []
    reviews.each do |review|
      r = {}
      r[:date] =  review.elements['Date/text()'].to_s
      r[:summary] =  review.elements['Summary/text()'].to_s
      r[:content] =  review.elements['Content/text()'].to_s
      comments << r
    end
    return comments
  rescue
    []
  end

  def self.pickup(keyword = nil)
    return nil if self.numdocs < 10
    resource = nil
    if keyword
      resources = self.find_id_by_solr(keyword, :limit => self.numdocs)
      resource = self.find(resources.results[rand(resources.total_hits)]) rescue nil
    end
    if resource.blank?
      while resource.nil?
        resource = self.find(rand(self.numdocs)) rescue nil
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
      unless patron = Patron.find(:first, :conditions => {:full_name => patron_list}) rescue nil
        patron = Patron.new(:full_name => patron_list, :language_id => 1)
        patron.access_role = Role.find(:first, :conditions => {:name => 'Guest'})
      end
      patron.save
      patrons << patron
    end
    return patrons
  end

  def self.import_isbn(isbn)
    isbn = isbn.to_s.strip
    raise 'invalid ISBN' unless ISBN_Tools.is_valid?(isbn)
    if isbn.length == 10
      isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
    end

    if manifestation = Manifestation.find(:first, :conditions => {:isbn => isbn})
      raise 'already imported'
    end

    server = ["api.porta.ndl.go.jp", 210, "zomoku"]
    result = z3950query(isbn, server[0], server[1], server[2])
    if result.nil?
      if isbn.length == 10
        isbn = ISBN_Tools.isbn10_to_isbn13(isbn)
      elsif isbn.length == 13
        isbn = ISBN_Tools.isbn13_to_isbn10(isbn)
      end
      result = z3950query(isbn, server[0], server[1], server[2])
    end

    raise "not found" if result.nil?

    title, title_transcription, date_of_publication, language = nil, nil, nil, nil
    authors, publishers, subjects = [], [], []

    result.to_s.split("\n").each do |line|
      if md = /^【title】：+(.*)$/.match(line) 
        title = md[1].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
      elsif md = /^【titleTranscription】：+(.*)$/.match(line) 
        title_transcription = md[1].sub(/\.$/, '').tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
      elsif md = /^【creator】\(dcndl:NDLNH\)：+(.*)$/.match(line)
        authors << md[1].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ') 
      elsif md = /^【publisher】：+(.*)$/.match(line)
        publishers << md[1].tr('ａ-ｚＡ-Ｚ０-９　‖', 'a-zA-Z0-9 ').squeeze(' ')
      elsif md = /^【subject】\(dcndl:NDLNH\)：+(.*)$/.match(line)
        subjects << md[1].tr('ａ-ｚＡ-Ｚ０-９　', 'a-zA-Z0-9 ').squeeze(' ')
      elsif md = /^【issued】\(dcterms:W3CDTF\)：+(.*)$/.match(line)
        date_of_publication = Time.mktime(md[1])
      elsif md = /^【language】\(dcterms:ISO639-2\)：+(.*)$/.match(line)
        language = md[1]
      end
    end

    Patron.transaction do
      author_patrons = Manifestation.import_patrons(authors.reverse)
      publisher_patrons = Manifestation.import_patrons(publishers)

    #end

    #Work.transaction do
      work = Work.new(:original_title => title)
      expression = Expression.new(:original_title => title, :expression_form_id => 1, :frequency_of_issue_id => 1, :language_id => 1)
      manifestation = Manifestation.create!(:original_title => title, :manifestation_form_id => 1, :language_id => 1, :isbn => isbn, :date_of_publication => date_of_publication)
      work.save!
      work.patrons << author_patrons
      work.expressions << expression
      expression.manifestations << manifestation
      manifestation.patrons << publisher_patrons

      subjects.each do |term|
        subject = Subject.find(:first, :conditions => {:term => term})
        manifestation.subjects << subject if subject
      end
    end

    return manifestation
  end

  def self.z3950query (isbn, host, port, db)
    begin
      ZOOM::Connection.open(host, port) do |conn|
        conn.database_name = db
        conn.preferred_record_syntax = 'SUTRS'
        rset = conn.search("@attr 1=7 #{isbn}")
        return rset[0]
      end
    rescue Exception => e
      return nil
    end
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

  def reservable?(user)
    return false if Reserve.waiting.find(:first, :conditions => {:user_id => user.id, :manifestation_id => self.id})
    true
  end

  def checkouts(from_date, to_date)
    Checkout.completed(from_date, to_date).find(:all, :conditions => {:item_id => self.items.collect(&:id)})
  end

  def bookmarks(from_date = nil, to_date = nil)
    if from_date.blank? and to_date.blank?
      if self.bookmarked_resource
        self.bookmarked_resource.bookmarks
      else
        []
      end
    else
      Bookmark.bookmarked(from_date, to_date).find(:all, :conditions => {:bookmarked_resource_id => self.bookmarked_resource.id})
    end
  end
end
