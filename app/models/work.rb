# == Schema Information
#
# Table name: works
#
#  id                          :integer          not null, primary key
#  original_title              :text             not null
#  title_transcription         :text
#  title_alternative           :text
#  context                     :text
#  form_of_work_id             :integer          default(1), not null
#  note                        :text
#  creates_count               :integer          default(0), not null
#  reifies_count               :integer          default(0), not null
#  resource_has_subjects_count :integer          default(0), not null
#  lock_version                :integer          default(0), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  deleted_at                  :datetime
#  required_role_id            :integer          default(1), not null
#  state                       :string(255)
#  required_score              :integer          default(0), not null
#  medium_of_performance_id    :integer          default(1), not null
#  parent_of_series            :boolean          default(FALSE), not null
#  series_statement_id         :integer
#  work_identifier             :string(255)
#

# -*- encoding: utf-8 -*-
class Work < ActiveRecord::Base
  has_many :creates, :dependent => :destroy
  has_many :patrons, :through => :creates
  has_many :reifies, :dependent => :destroy
  has_many :expressions, :through => :reifies
  belongs_to :form_of_work #, :validate => true
  has_many :work_merges, :dependent => :destroy
  has_many :work_merge_lists, :through => :work_merges
  has_many :work_has_subjects, :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true
  has_many :children, :foreign_key => 'parent_id', :class_name => 'WorkRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'WorkRelationship', :dependent => :destroy
  has_many :derived_works, :through => :children, :source => :child
  has_many :original_works, :through => :parents, :source => :parent
  #has_many :work_has_concepts, :dependent => :destroy
  #has_many :concepts, :through => :work_has_concepts
  #has_many :work_has_places, :dependent => :destroy
  #has_many :places, :through => :work_has_places
  #has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :work_has_subjects
  #has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :creates
  belongs_to :medium_of_performance
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
    integer :manifestation_ids, :multiple => true do
      expressions.collect(&:manifestations).flatten.collect(&:id)
    end
    integer :series_statement_id
  end

  #acts_as_soft_deletable
  #acts_as_tree
  has_paper_trail

  validates_associated :form_of_work
  validates_presence_of :original_title, :form_of_work_id
  alias :creators :patrons

  paginates_per 10

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
    #expressions.collect(&:manifestations).flatten.uniq
    Manifestation.search do
      with(:work_ids).equal_to self.id
    end.results
  end

  #def serials
  #end

  def work_merge_lists_ids
    self.work_merge_lists.collect(&:id)
  end

  def created(patron)
    creates.where(:patron_id => patron.id).first
  end

  def reified(expression)
    reifies.where(:expression_id => expression.id).first
  end

  def expire_cache
    Rails.cache.fetch("work_screen_shot_#{id}")
    Rails.cache.write("work_search_total", Work.search.total)
  end

  def self.cached_numdocs
    Rails.cache.fetch("work_search_total"){Work.search.total}
  end
end
