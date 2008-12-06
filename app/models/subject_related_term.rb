class SubjectRelatedTerm < ActiveRecord::Base
  belongs_to :subject, :class_name => 'Subject', :foreign_key => 'subject_id', :validate => true
  belongs_to :related_term, :class_name => 'Subject', :foreign_key => 'related_term_id', :validate => true

  validates_associated :subject, :related_term
  validates_presence_of :subject, :related_term
  validates_uniqueness_of :related_term_id, :scope => :subject_id
end
