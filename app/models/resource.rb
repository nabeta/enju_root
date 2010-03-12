class Resource < ActiveRecord::Base
  include OnlyLibrarianCanModify
  has_friendly_id :iss_token
  has_paper_trail
  #acts_as_archive :indexes => [:id, :iss_token, :work_token]

  default_scope :order => 'updated_at DESC'
  named_scope :approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND approved IS true', from_time, until_time]}}
  named_scope :not_approved, lambda {|from_time, until_time| {:conditions => ['updated_at >= ? AND updated_at <= ? AND approved IS false', from_time, until_time]}}

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

  def per_page
    10
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
