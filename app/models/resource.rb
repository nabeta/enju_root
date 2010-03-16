class Resource < ActiveRecord::Base
  include AASM
  include OnlyLibrarianCanModify
  has_friendly_id :iss_token
  has_paper_trail
  #acts_as_archive :indexes => [:id, :iss_token, :work_token]

  default_scope :order => 'updated_at DESC'
  named_scope :approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'approved']}}
  named_scope :not_approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND state = ?', from_time, until_time, 'not_approved']}}

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

  aasm_initial_state :pending

  aasm_event :aasm_ask_for_approval do
    transitions :from => [:pending, :published, :approved, :not_approved, :rejected],
      :to => :not_approved
  end

  aasm_event :aasm_approve do
    transitions :from => [:not_approved],
      :to => :approved
  end

  aasm_event :aasm_publish do
    transitions :from => [:approved],
      :to => :published,
      :on_transition => :clear_approval
  end
  #TODO: 却下処理

  def per_page
    10
  end

  def before_save
    if state == 'approved' and approved
      aasm_publish
      return
    end
    if approved_change
      if approved_change[0] == false
        aasm_approve
      end
    else
      aasm_ask_for_approval
    end
  end

  def ask_for_approval
    aasm_ask_for_approval
  end

  def clear_approval
    self.approved = false
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

  def last_approved
    if approved
      self
    else
      versions.reverse.map{|version| version.reify}.find do |r|
        r.try(:approved)
      end
    end
  end
end
