class Subject < ActiveRecord::Base
  include OnlyAdministratorCanModify
  include EnjuFragmentCache

  has_many :work_has_subjects, :dependent => :destroy
  has_many :works, :through => :work_has_subjects #, :source => :subjectable, :source_type => 'Work'
  #has_many :expressions, :through => :work_has_subjects, :source => :subjectable, :source_type => 'Expression', :include => :content_type
  #has_many :manifestations, :through => :work_has_subjects, :source => :subjectable, :source_type => 'Manifestation', :include => :carrier_type
  #has_many :items, :through => :work_has_subjects, :source => :subjectable, :source_type => 'Item'
  #has_many :patrons, :through => :work_has_subjects, :source => :subjectable, :source_type => 'Patron'

  #has_many :subject_used_for_terms, :class_name => 'SubjectUsedForTerm', :foreign_key => 'used_for_term_id'
  #has_many :used_for_terms, :through => :subject_used_for_terms, :source => :subject
  #has_many :subject_uses_for_terms, :class_name => 'SubjectUsedForTerm', :foreign_key => 'subject_id'
  #has_many :uses_fors, :through => :subject_uses_for_terms, :source => :used_for_term

  has_many :subject_broader_terms, :class_name => 'SubjectBroaderTerm', :foreign_key => 'broader_term_id'
  has_many :broader_terms, :through => :subject_broader_terms, :source => :narrower_term
  has_many :subject_narrower_terms, :class_name => 'SubjectBroaderTerm', :foreign_key => 'narrower_term_id'
  has_many :narrower_terms, :through => :subject_narrower_terms, :source => :broader_term

  has_many :subject_from_related_terms, :class_name => 'SubjectRelatedTerm', :foreign_key => 'subject_id'
  has_many :related_terms, :through => :subject_from_related_terms, :source => :related_term
  has_many :subject_to_related_terms, :class_name => 'SubjectRelatedTerm', :foreign_key => 'related_term_id'
  has_many :subjects, :through => :subject_to_related_terms, :source => :subject

  has_many :use_terms, :class_name => 'Subject', :foreign_key => :use_term_id
  belongs_to :use_term, :class_name => 'Subject', :foreign_key => :use_term_id, :validate => true
  has_many :subject_has_classifications, :dependent => :destroy
  has_many :classifications, :through => :subject_has_classifications
  belongs_to :subject_type, :validate => true
  has_many :subject_heading_type_has_subjects
  has_many :subject_heading_types, :through => :subject_heading_type_has_subjects

  validates_associated :use_term, :subject_type
  validates_presence_of :term, :subject_type

  searchable :auto_index => false do
    text :term, :term_transcription, :note
    string :term
    time :created_at
    time :updated_at
    integer :work_ids, :multiple => true
    integer :classification_ids, :multiple => true
    integer :subject_heading_type_ids, :multiple => true
  end
  #acts_as_soft_deletable
  acts_as_tree

  @@per_page = 10
  cattr_accessor :per_page

  #def tags
  #  self.works.collect(&:tags).flatten
  #end

end
