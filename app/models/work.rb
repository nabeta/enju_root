# -*- encoding: utf-8 -*-
class Work < ActiveRecord::Base
  include OnlyLibrarianCanModify
  include EnjuFragmentCache
  include SolrIndex

  has_many :creates, :dependent => :destroy, :order => :position
  has_many :patrons, :through => :creates, :order => 'creates.position'
  has_many :reifies, :dependent => :destroy, :order => :position
  has_many :expressions, :through => :reifies
  belongs_to :form_of_work #, :validate => true
  has_many :work_merges, :dependent => :destroy
  has_many :work_merge_lists, :through => :work_merges
  has_many :work_has_subjects, :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  has_many :to_works, :foreign_key => 'from_work_id', :class_name => 'WorkHasWork'#, :dependent => :destroy
  has_many :from_works, :foreign_key => 'to_work_id', :class_name => 'WorkHasWork'#, :dependent => :destroy
  has_many :derived_works, :through => :to_works, :source => :to_work
  has_many :original_works, :through => :from_works, :source => :from_work
  #has_many :work_has_concepts, :dependent => :destroy
  #has_many :concepts, :through => :work_has_concepts
  #has_many :work_has_places, :dependent => :destroy
  #has_many :places, :through => :work_has_places
  #has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :work_has_subjects
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :creates
  belongs_to :medium_of_performance
  has_many :subscribes, :dependent => :destroy
  has_many :subscriptions, :through => :subscribes
  belongs_to :series_statement

  accepts_nested_attributes_for :expressions, :allow_destroy => true

  searchable do
    text :title, :context, :note, :author
    text :author do
      patrons.collect(&:full_name) + patrons.collect(&:full_name_transcription)
    end
    time :created_at
    time :updated_at
    integer :patron_ids, :multiple => true
    integer :work_merge_list_ids, :multiple => true
    integer :original_work_ids, :multiple => true
    integer :required_role_id
    integer :form_of_work_id
    integer :subject_ids, :multiple => true
    boolean :parent_of_series
    integer :manifestation_ids, :multiple => true do
      expressions.collect(&:manifestations).flatten.collect(&:id)
    end
    integer :subscription_ids, :multiple => true
  end

  #acts_as_soft_deletable
  #acts_as_tree
  has_paper_trail

  @@per_page = 10
  cattr_accessor :per_page

  validates_associated :form_of_work
  validates_presence_of :original_title, :form_of_work_id

  def title
    array = titles
    #if expressions
    #  title_array << expressions.collect(&:titles) + expressions.collect(&:manifestations).flatten.collect(&:titles)
    #end
    array.flatten.compact.sort.uniq
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
  
  def manifestations
    expressions.collect(&:manifestations).flatten.uniq
  end

  #def serials
  #end

  def work_merge_lists_ids
    self.work_merge_lists.collect(&:id)
  end

  def created(patron)
    creates.first(:conditions => {:patron_id => patron.id})
  end

  def reified(expression)
    reifies.first(:conditions => {:expression_id => expression.id})
  end

  def subscribed?(time = Time.zone.now)
    if subscribe = subscribes.first(:order => 'end_at DESC')
      if subscribe.end_at
        return true if subscribe.start_at <= time and subscribe.end_at >= time
      end
    end
    false
  end

end
