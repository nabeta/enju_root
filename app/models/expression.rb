# -*- encoding: utf-8 -*-
class Expression < ActiveRecord::Base
  include EnjuFragmentCache

  has_one :reify, :dependent => :destroy
  has_one :work, :through => :reify
  has_many :embodies, :dependent => :destroy
  has_many :manifestations, :through => :embodies
  has_many :realizes, :dependent => :destroy
  has_many :patrons, :through => :realizes
  belongs_to :language #, :validate => true
  has_many :expression_merges, :dependent => :destroy
  has_many :expression_merge_lists, :through => :expression_merges
  #has_many :work_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :work_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ExpressionRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ExpressionRelationship', :dependent => :destroy
  has_many :derived_expressions, :through => :children, :source => :child
  has_many :original_expressions, :through => :parents, :source => :parent
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :realizes
  belongs_to :content_type
  
  validates_associated :content_type, :language
  validates_presence_of :content_type_id, :language_id, :original_title
  
  searchable do
    text :title, :summarization, :context, :note
    text :creator do
      creators.collect(&:full_name) + creators.collect(&:full_name_transcription) if creators
    end
    time :created_at
    time :updated_at
    integer :patron_ids, :multiple => true
    integer :manifestation_ids, :multiple => true
    integer :expression_merge_list_ids, :multiple => true
    integer :work_id
    integer :content_type_id
    integer :language_id
    integer :required_role_id
    integer :original_expression_ids, :multiple => true
  end
  #acts_as_tree
  #acts_as_soft_deletable
  has_paper_trail

  attr_accessor :new_work_id
  alias :contributors :patrons

  def self.per_page
    10
  end

  def title
    title_array = titles
    #title_array << self.work.titles if self.work
    #title_array << self.manifestations.collect(&:titles)
    title_array.flatten.compact.sort.uniq
  end

  def titles
    title = []
    title << original_title
    title << title_transcription
    title << title_alternative
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title
  end

  def creators
    self.work.patrons if self.work
  end

  def work_id
    self.work.id if self.work
  end

  def expression_merge_list_ids
    self.expression_merge_lists.collect(&:id)
  end

  def realized(patron)
    realizes.first(:conditions => {:patron_id => patron.id})
  end

  def embodied(manifestation)
    embodies.first(:conditions => {:manifestation_id => manifestation.id})
  end

end
