class Resource < ActiveRecord::Base
  has_friendly_id :iss_token
  has_paper_trail
  enju_oai
  #acts_as_archive :indexes => [:id, :iss_token, :work_token]

  default_scope :order => 'updated_at DESC'
  named_scope :approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'approved']}}
  named_scope :not_approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'not_approved']}}
  named_scope :published, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'published']}}
  named_scope :all_record, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ?', from_time, until_time]}}
  named_scope :not_deleted, :conditions => ['deleted_at IS NULL']
  named_scope :deleted, :conditions => ['deleted_at IS NOT NULL']

  validates_presence_of :iss_token
  validates_uniqueness_of :iss_token

  belongs_to :manifestation

  #searchable do
  #  text :title
  #  string :work_token
  #  string :language
  #  string :classification
  #  string :pubdate
  #  time :created_at
  #  time :updated_at
  #  time :deleted_at
  #end

  state_machine :initial => :not_approved do
    event :sm_ask_for_approval do
      transition any => :not_approved
    end

    event :sm_approve do
      transition :not_approved => :approved
    end

    event :sm_publish do
      transition [:approved, :published] => :published
    end
  end
  #TODO: 却下処理

  attr_accessor :approve, :publish, :status_changed
  #before_validation :set_status

  def per_page
    10
  end

  def before_validation_on_create
    generate_iss_token
  end

  def set_status
    if ['approved', 'published'].include?(state) and publish == '1'
      sm_publish
      return
    end
    if state == 'not_approved' and approve == '1'
      sm_approve
    else
      sm_ask_for_approval
    end
  end

  def dcndl
    Nokogiri::XML(dcndl_xml)
  end

  def title
    # 表示用にXMLを読んでタイトルを取得
    dcndl.at('//xmlns:feed/xmlns:title').text
  rescue
    nil
  end

  def original_title
    title
  end

  def language
  end

  def classification
  end

  def pubdate
  end

  def last_published
    if state == 'published'
      self
    else
      versions.reverse.map{|version| version.reify}.find do |r|
        r.try(:state) == 'published'
      end
    end
  end

  def editable?
    ['not_approved'].include?(state)
  end

  def publishable?
    ['approved'].include?(state)
  end

  def is_readable_by(user, parent = nil)
    if state == 'published'
      true
    else
      true if user.try(:has_role?, 'Administrator')
    end
  rescue
    false
  end

  def oai_identifier
    #"oai:#{LIBRARY_WEB_HOSTNAME}:#{self.class.to_s.tableize}-#{iss_token}"
    "oai:#{LIBRARY_WEB_HOSTNAME}:#{iss_token}"
  end

  def generate_iss_token
    self.iss_token = Digest::SHA1.hexdigest([Time.now, (1..10).map{ rand.to_s }].flatten.join('--')) unless self.iss_token
  end
end
