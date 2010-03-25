class Resource < ActiveRecord::Base
  include AASM
  include OnlyLibrarianCanModify
  has_friendly_id :iss_token
  has_paper_trail
  enju_oai
  #acts_as_archive :indexes => [:id, :iss_token, :work_token]

  default_scope :order => 'updated_at DESC'
  named_scope :approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'approved']}}
  named_scope :not_approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'not_approved']}}
  named_scope :published, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'published']}}
  named_scope :all_record, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ?', from_time, until_time]}}

  validates_presence_of :iss_token
  validates_uniqueness_of :iss_token

  belongs_to :manifestation

  #searchable do
  #  text :title
  #  string :work_token
  #  string :language
  #  string :classification
  #  string :pubdate
  #end

  aasm_column :state
  aasm_state :pending
  aasm_state :published
  aasm_state :not_approved
  aasm_state :approved
  aasm_state :rejected

  #aasm_initial_state :pending
  aasm_initial_state :not_approved

  aasm_event :aasm_ask_for_approval do
    transitions :from => [:pending, :published, :approved, :not_approved, :rejected],
      :to => :not_approved
  end

  aasm_event :aasm_approve do
    transitions :from => [:not_approved],
      :to => :approved
  end

  aasm_event :aasm_publish do
    transitions :from => [:approved, :published],
      :to => :published
  end
  #TODO: 却下処理

  attr_accessor :approve, :publish

  def per_page
    10
  end

  def before_save
    if ['approved', 'published'].include?(state) and publish == '1'
      aasm_publish
      return
    end
    if state == 'not_approved' and approve == '1'
      aasm_approve
    else
      aasm_ask_for_approval
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
      true if user.try(:has_role?, 'Librarian')
    end
  rescue
    false
  end
end
