class Subject < ActiveRecord::Base
  has_many :resource_has_subjects, :dependent => :destroy
  has_many :works, :through => :resource_has_subjects, :source => :subjectable, :source_type => 'Work', :include => :work_form
  has_many :expressions, :through => :resource_has_subjects, :source => :subjectable, :source_type => 'Expression', :include => :expression_form
  has_many :manifestations, :through => :resource_has_subjects, :source => :subjectable, :source_type => 'Manifestation', :include => :manifestation_form
  has_many :items, :through => :resource_has_subjects, :source => :subjectable, :source_type => 'Item'
  has_many :patrons, :through => :resource_has_subjects, :source => :subjectable, :source_type => 'Patron'

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
  has_many :classifications, :through => :subject_has_classifications, :include => :classification_type
  belongs_to :subject_type, :validate => true
  has_many :subject_heading_type_has_subjects
  has_many :subject_heading_types, :through => :subject_heading_type_has_subjects

  validates_associated :use_term, :subject_type
  validates_presence_of :term, :subject_type

  acts_as_solr :fields => [:term, :term_transcription, :note, :tags,
    {:manifestation_ids => :integer}, {:classification_ids => :integer}],
    :auto_commit => false
  acts_as_tree
  @@per_page = 10
  cattr_reader :per_page

  def tags
    self.manifestations.collect(&:tags).flatten
  end

  def manifestation_ids
    self.manifestations.collect(&:id)
  end

  def classification_ids
    self.classifications.collect(&:id)
  end

end
