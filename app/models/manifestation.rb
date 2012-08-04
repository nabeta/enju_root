# == Schema Information
#
# Table name: manifestations
#
#  id                              :integer          not null, primary key
#  original_title                  :text             not null
#  title_alternative               :text
#  title_transcription             :text
#  classification_number           :string(255)
#  identifier                      :string(255)
#  date_of_publication             :datetime
#  date_copyrighted                :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  deleted_at                      :datetime
#  access_address                  :string(255)
#  language_id                     :integer          default(1), not null
#  carrier_type_id                 :integer          default(1), not null
#  extent_id                       :integer          default(1), not null
#  start_page                      :integer
#  end_page                        :integer
#  height                          :integer
#  width                           :integer
#  depth                           :integer
#  isbn                            :string(255)
#  isbn10                          :string(255)
#  wrong_isbn                      :string(255)
#  nbn                             :string(255)
#  lccn                            :string(255)
#  oclc_number                     :string(255)
#  issn                            :string(255)
#  price                           :integer
#  fulltext                        :text
#  volume_number_list              :string(255)
#  issue_number_list               :string(255)
#  serial_number_list              :string(255)
#  edition                         :integer
#  note                            :text
#  produces_count                  :integer          default(0), not null
#  exemplifies_count               :integer          default(0), not null
#  embodies_count                  :integer          default(0), not null
#  resource_has_subjects_count     :integer          default(0), not null
#  repository_content              :boolean          default(FALSE), not null
#  lock_version                    :integer          default(0), not null
#  required_role_id                :integer          default(1), not null
#  state                           :string(255)
#  required_score                  :integer          default(0), not null
#  frequency_id                    :integer          default(1), not null
#  subscription_master             :boolean          default(FALSE), not null
#  series_statement_id             :integer
#  attachment_file_name            :string(255)
#  attachment_content_type         :string(255)
#  attachment_file_size            :integer
#  attachment_updated_at           :datetime
#  nii_type_id                     :integer
#  title_alternative_transcription :text
#  description                     :text
#  abstract                        :text
#  available_at                    :datetime
#  valid_until                     :datetime
#  date_submitted                  :datetime
#  date_accepted                   :datetime
#  date_caputured                  :datetime
#  file_hash                       :string(255)
#  pub_date                        :string(255)
#  periodical_master               :boolean          default(FALSE), not null
#  year_of_publication             :integer
#  attachment_fingerprint          :string(255)
#

# -*- encoding: utf-8 -*-
#require 'wakati'
require 'timeout'

class Manifestation < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  scope :pictures, where(:attachment_content_type => ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png'])
  scope :serials, :conditions => ['frequency_id > 1']
  scope :not_serials, where(:frequency_id => 1)
  has_many :embodies, :dependent => :destroy
  has_many :expressions, :through => :embodies
  has_many :exemplifies, :dependent => :destroy
  has_many :items, :through => :exemplifies, :dependent => :destroy
  has_many :produces, :dependent => :destroy
  has_many :patrons, :through => :produces
  #has_one :manifestation_api_response, :dependent => :destroy
  belongs_to :carrier_type #, :validate => true
  belongs_to :extent #, :validate => true
  belongs_to :language, :validate => true
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  #has_many :orders, :dependent => :destroy
  #has_many :work_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :work_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :bookmark_stat_has_manifestations
  has_many :bookmark_stats, :through => :bookmark_stat_has_manifestations
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :derived_manifestations, :through => :children, :source => :child
  has_many :original_manifestations, :through => :parents, :source => :parent
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :produces
  belongs_to :frequency #, :validate => true
  belongs_to :nii_type
  belongs_to :series_statement
  has_one :import_request
  has_one :resource
  has_one :resource_import_result

  searchable do
    text :title, :default_boost => 2
    text :fulltext, :note, :creator, :contributor, :publisher, :subject, :description
    string :title, :multiple => true
    # text フィールドだと区切りのない文字列の index が上手く作成
    #できなかったので。 downcase することにした。
    #他の string 項目も同様の問題があるので、必要な項目は同様の処置が必要。
    string :connect_title do
      title.join('').gsub(/\s/, '').downcase
    end
    string :connect_creator do
      creator.join('').gsub(/\s/, '').downcase
    end
    string :connect_publisher do
      publisher.join('').gsub(/\s/, '').downcase
    end
    string :isbn, :multiple => true do
      [isbn, isbn10, wrong_isbn]
    end
    string :issn
    string :lccn
    string :nbn
    string :carrier_type do
      carrier_type.name
    end
    string :library, :multiple => true
    string :language, :multiple => true do
      languages.collect(&:name)
    end
    string :shelf, :multiple => true
    string :subject, :multiple => true
    string :classification, :multiple => true do
      classifications.collect(&:category)
    end
    string :sort_title
    string :item_identifier, :multiple => true do
      items.collect(&:item_identifier)
    end
    time :created_at
    time :updated_at
    time :deleted_at
    time :date_of_publication
    integer :patron_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_manifestation_ids, :multiple => true
    integer :derived_manifestation_ids, :multiple => true
    integer :expression_ids, :multiple => true
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
    integer :subject_ids, :multiple => true do
      self.subjects.collect(&:id)
    end
    float :price
    integer :series_statement_id
    boolean :repository_content
    # for OpenURL
    text :aulast do
      creators.map{|creator| creator.last_name}
    end
    text :aufirst do
      creators.map{|creator| creator.first_name}
    end
    # OTC start
    string :creator, :multiple => true do
      creator.map{|au| au.gsub(' ', '')}
    end
    text :au do
      creator
    end
    text :atitle do
      title if original_manifestations.present? # 親がいることが条件
    end
    text :btitle do
      title if frequency_id == 1  # 発行頻度1が単行本
    end
    text :jtitle do
      if frequency_id != 1  # 雑誌の場合
        title
      else                  # 雑誌以外（雑誌の記事も含む）
        titles = []
        original_manifestations.each do |m|
          if m.frequency_id != 1
            titles << m.title
          end
        end
        titles.flatten
      end
    end
    text :isbn do  # 前方一致検索のためtext指定を追加
      [isbn, isbn10, wrong_isbn]
    end

    text :issn  # 前方一致検索のためtext指定を追加
    text :ndl_jpno do
      # TODO 詳細不明
    end
    string :ndl_dpid do
      # TODO 詳細不明
    end
    # OTC end
    integer :work_ids, :multiple => true do
      expressions.collect(&:work_id)
    end
  end

  #acts_as_tree
  enju_manifestation_viewer
  #enju_amazon
  #enju_ndl
  #enju_cinii
  has_attached_file :attachment
  #has_ipaper_and_uses 'Paperclip'
  #enju_scribd
  enju_oai
  #enju_calil_check
  #enju_worldcat
  has_paper_trail

  attr_accessor :new_expression_id

  validates_presence_of :original_title, :carrier_type_id, :language_id
  validates_associated :carrier_type, :language
  validates_numericality_of :start_page, :end_page, :allow_blank => true
  validates_length_of :access_address, :maximum => 255, :allow_blank => true
  validates_uniqueness_of :isbn, :allow_blank => true
  validates_uniqueness_of :nbn, :allow_blank => true
  validates_uniqueness_of :identifier, :allow_blank => true
  validates_format_of :access_address, :with => URI::regexp(%w(http https)) , :allow_blank => true
  validate :check_isbn
  before_validation :convert_isbn
  normalize_attributes :identifier, :date_of_publication, :isbn, :issn, :nbn, :lccn

  before_save :set_date_of_publication
  alias :producers :patrons

  paginates_per 10

  def check_isbn
    if isbn.present?
      unless StdNum::ISBN.valid?(isbn)
        errors.add(:isbn)
      end
    end
  end

  def check_issn
    self.issn = StdNum::ISSN.normalize(issn)
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def check_lccn
    if lccn.present?
      unless StdNum::LCCN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def set_wrong_isbn
    if isbn.present?
      unless StdNum::ISBN.valid?(isbn)
        self.wrong_isbn
        self.isbn = nil
      end
    end
  end

  def convert_isbn
    return nil unless isbn
    lisbn = Lisbn.new(isbn)
    if lisbn.isbn
      if lisbn.isbn.length == 10
        self.isbn10 = lisbn.isbn10
        self.isbn = lisbn.isbn13
      elsif lisbn.isbn.length == 13
        self.isbn = lisbn.isbn10
        self.isbn = lisbn.isbn13
      end
    end
  end

  def set_date_of_publication
    return if pub_date.blank?
    date = nil
    pub_date_string = pub_date

    while date.nil? do
      pub_date_string += '-01'
      break if date =~ /-01-01-01$/
      begin
        date = Time.zone.parse(pub_date_string)
      rescue ArgumentError
        date = nil
      rescue TZInfo::AmbiguousTime
        self.year_of_publication = pub_date_string.to_i if pub_date_string =~ /^\d+$/
        break
      end
    end

    if date
      self.year_of_publication = date.year
      if date.year > 0
        self.date_of_publication = date
      end
    end
  end

  def expire_cache
    #Rails.cache.delete("worldcat_record_#{id}")
    #Rails.cache.delete("xisbn_manifestations_#{id}")
    Rails.cache.fetch("manifestation_screen_shot_#{id}")
    Rails.cache.write("manifestation_search_total", Manifestation.search.total)
  end

  def self.cached_numdocs
    Rails.cache.fetch("manifestation_search_total"){Manifestation.search.total}
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
    title << original_title.to_s.strip
    title << title_transcription.to_s.strip
    title << title_alternative.to_s.strip
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title
  end

  def url
    #access_address
    "#{LibraryGroup.site_config.url}#{self.class.to_s.tableize}/#{self.id}"
  end

  def embodies?(expression)
    expression.manifestations.detect{|manifestation| manifestation == self}
  end

  def serial?
    return true if series_statement
    #return true if parent_of_series
    #return true if frequency_id > 1
    false
  end

  def parent_of_series
    id = self.id
    Work.search do
      with(:manifestation_ids).equal_to id
      without(:series_statement_id).equal_to nil
    end.results.first
    # TODO: parent_of_series をシリーズ中にひとつしか作れないようにする
  end

  def create_next_issue_work_and_expression
    return nil unless parent_of_series
    work = Work.create(
      :original_title => parent_of_series.original_title,
      :title_alternative => parent_of_series.title_alternative,
      :title_transcription => parent_of_series.title_transcription,
      :context => parent_of_series.context,
      :form_of_work_id => parent_of_series.form_of_work_id,
      :medium_of_performance_id => parent_of_series.medium_of_performance_id,
      :required_role_id => parent_of_series.required_role_id
    )
    expression = Expression.new(
      :original_title => parent_of_series.original_title,
      :title_alternative => parent_of_series.title_alternative,
      :title_transcription => parent_of_series.title_transcription,
      :language_id => self.language_id
    )
    work.expressions << expression
    work.patrons << parent_of_series.patrons
    self.expressions << expression
  end

  def creators
    # 著編者
    (self.works.collect{|w| w.patrons}.flatten + self.expressions.collect{|e| e.patrons}.flatten).uniq
  end

  def contributors
    patrons = []
    self.expressions.each do |expression|
      patrons += expression.patrons.uniq
    end
    patrons -= creators
  end

  def publishers
    self.patrons
  end

  def shelves
    self.items.collect{|item| item.shelves}.flatten.uniq
  end

  def works
    self.expressions.collect{|e| e.work}.uniq.compact
  end

  def patron
    self.patrons.collect(&:name) + self.expressions.collect{|e| e.patrons.collect(&:name) + e.work.patrons.collect(&:name)}.flatten
  end

  def shelf
    self.items.collect{|i| i.shelf.library.name + i.shelf.name}
  end

  def related_manifestations
    # TODO: 定期刊行物をモデルとビューのどちらで抜くか
    manifestations = self.works.collect{|w| w.expressions.collect{|e| e.manifestations}}.flatten.uniq.compact + self.original_manifestations + self.derived_manifestations - Array(self)
  end

  def sort_title
    # 並べ替えの順番に使う項目を指定する
    # TODO: 日本語以外の資料、読みが入力されていない資料
    NKF.nkf('-w --katakana', title_transcription) if title_transcription
  end

  def classifications
    subjects.collect(&:classifications).flatten
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

  def creator
    creators.collect(&:name).flatten
  end

  def editor
    contributor
  end

  def contributor
    contributors.collect(&:name).flatten
  end

  def subject
    subjects.collect(&:term) + subjects.collect(&:term_transcription)
  end

  def isbn13
    isbn
  end

  def hyphenated_isbn
    lisbn = Lisbn.new(isbn)
    lisbn.parts.join('-')
  end

  def subjects
    self.works.collect(&:subjects).flatten
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    manifestation = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Sunspot.search(Manifestation) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    manifestation = response.results.first
  end

  def set_serial_number
    if m = series_statement.try(:last_issue)
      self.original_title = m.original_title
      self.title_transcription = m.title_transcription
      self.title_alternative = m.title_alternative
      self.issn = m.issn
      unless m.serial_number_list.blank?
        self.serial_number_list = m.serial_number_list.to_i + 1
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
        else
          self.issue_number_list = m.issue_number_list
        end
        self.volume_number_list = m.volume_number_list
      else
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
          self.volume_number_list = m.volume_number_list
        else
          unless m.volume_number_list.blank?
            self.volume_number_list = m.volume_number_list.split.last.to_i + 1
          end
        end
      end
    end
    return self
  end

  def extract_text
    return nil unless attachment.path
    # TODO: S3 support
    response = `curl "#{Sunspot.config.solr.url}/update/extract?&extractOnly=true&wt=ruby" --data-binary @#{attachment.path} -H "Content-type:text/html"`
    self.fulltext = eval(response)[""]
    save(:validate => false)
  end

  def derived_manifestations_by_solr(options = {})
    page = options[:page] || 1
    sort_by = options[:sort_by] || 'created_at'
    order = options[:order] || 'desc'
    manifestation_id = id
    search = Sunspot.new_search(Manifestation)
    search.build do
      with(:original_manifestation_ids).equal_to manifestation_id
      order_by(sort_by, order)
    end
    search.query.paginate page.to_i, Manifestation.default_per_page
    search.execute!.results
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def bookmarks_count
    self.bookmarks.size
  end

  def produced(patron)
    produces.where(:patron_id => patron.id).first
  end

  def embodied(expression)
    embodies.where(:expression_id => expression.id).first
  end

  def check_series_statement
    if series_statement
      errors.add(:series_statement) unless series_statement.work
    end
  end

  def bookmark_for(user)
    Bookmark.where(:user_id => user.id, :manifestation_id => self.id).first
  end

  def has_single_work?
    return true if works.size == 0
    if works.size == 1
      return true if works.first.original_title == original_title
    end
    false
  end

  def web_item
    items.where(:shelf_id => Shelf.web.id).first
  end

  def self.find_by_isbn(isbn)
    lisbn = Lisbn.new(isbn.to_s)
    if lisbn.valid?
      if lisbn.isbn.size == 10
        Manifestation.where(:isbn => lisbn.isbn13).first || Manifestation.where(:isbn => lisbn.isbn10).first
      else
        Manifestation.where(:isbn => lisbn.isbn13).first || Manifestation.where(:isbn => lisbn.isbn10).first
      end
    end
  end

  # 仮実装
  def similar_works
    Work.where(:original_title => self.original_title)
  end

  def same_work?(manifestation)
    true unless (self.works & manifestation.works).empty?
  end
end
