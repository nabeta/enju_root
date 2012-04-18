# -*- encoding: utf-8 -*-
class Subject < ActiveRecord::Base
  has_many :work_has_subjects, :dependent => :destroy
  has_many :works, :through => :work_has_subjects
  has_many :use_terms, :class_name => 'Subject', :foreign_key => :use_term_id
  belongs_to :use_term, :class_name => 'Subject', :foreign_key => :use_term_id, :validate => true
  has_many :subject_has_classifications, :dependent => :destroy
  has_many :classifications, :through => :subject_has_classifications
  belongs_to :subject_type, :validate => true
  has_many :subject_heading_type_has_subjects
  has_many :subject_heading_types, :through => :subject_heading_type_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true

  validates_associated :use_term, :subject_type
  validates_presence_of :term, :subject_type

  searchable do
    text :term, :term_transcription, :note
    string :term
    time :created_at
    time :updated_at
    integer :work_ids, :multiple => true
    integer :classification_ids, :multiple => true
    integer :subject_heading_type_ids, :multiple => true
    integer :required_role_id
  end
  #acts_as_soft_deletable
  acts_as_nested_set

  attr_accessor :classification_id, :subject_heading_type_id

  def self.per_page
    10
  end

end
# == Schema Information
#
# Table name: subjects
#
#  id                      :integer         not null, primary key
#  parent_id               :integer
#  use_term_id             :integer
#  term                    :string(255)
#  term_transcription      :text
#  subject_type_id         :integer         not null
#  scope_note              :text
#  note                    :text
#  required_role_id        :integer         default(1), not null
#  work_has_subjects_count :integer         default(0), not null
#  lock_version            :integer         default(0), not null
#  created_at              :datetime
#  updated_at              :datetime
#  deleted_at              :datetime
#

