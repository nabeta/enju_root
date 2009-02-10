class Expression < ActiveRecord::Base
  named_scope :serials, :conditions => ['frequency_of_issue_id > 1']
  has_one :reify, :dependent => :destroy
  has_one :work, :through => :reify, :include => [:work_form]
  has_many :embodies, :dependent => :destroy
  has_many :manifestations, :through => :embodies, :include => [:manifestation_form]
  belongs_to :expression_form #, :validate => true
  #has_many :realizes, :dependent => :destroy, :order => :position
  #has_many :patrons, :through => :realizes
  belongs_to :language, :validate => true
  belongs_to :frequency_of_issue, :validate => true
  has_many :expression_merges, :dependent => :destroy
  has_many :expression_merge_lists, :through => :expression_merges
  #has_many :resource_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :resource_has_subjects
  has_one :subscribe, :dependent => :destroy
  has_one :subscription, :through => :subscribe
  belongs_to :access_role, :class_name => 'Role', :foreign_key => 'access_role_id', :validate => true
  has_many :to_expressions, :foreign_key => 'from_expression_id', :class_name => 'ExpressionHasExpression', :dependent => :destroy
  has_many :from_expressions, :foreign_key => 'to_expression_id', :class_name => 'ExpressionHasExpression', :dependent => :destroy
  has_many :derived_expressions, :through => :to_expressions, :source => :expression_to_expression
  has_many :original_expressions, :through => :from_expressions, :source => :expression_from_expression
  has_many_polymorphs :patrons, :from => [:people, :corporate_bodies, :families], :through => :realizes
  
  validates_associated :expression_form, :language, :frequency_of_issue
  validates_presence_of :expression_form, :language, :frequency_of_issue
  
  acts_as_tree
  acts_as_solr :fields => [:title, {:issn => :string}, :summarization, :context, :note, {:created_at => :date}, {:updated_at => :date}, :author,
    {:work_id => :integer}, {:manifestation_ids => :integer},
    {:patron_ids => :integer}, {:frequency_of_issue_id => :range_integer},
    {:subscription_id => :integer}, {:access_role_id => :range_integer},
    {:expression_merge_list_ids => :integer}],
    :facets => [:expression_form_id, :language_id], :if => proc{|expression| !expression.restrain_indexing}, :auto_commit => false
  acts_as_soft_deletable
  acts_as_taggable

  cattr_reader :per_page
  @@per_page = 10
  attr_accessor :restrain_indexing

  def serial?
    return true if self.frequency_of_issue_id > 1
    return false
  end
  
  def title
    array = []
    array << self.work.titles if self.work
    self.manifestations.each do |manifestation|
      array << manifestation.titles
    end
    array.flatten.compact
  end

  def titles
    title = []
    title << original_title
    title << title_transcription
    title << title_alternative
    title << original_title.wakati
    title << title_transcription.wakati rescue nil
    title << title_alternative.wakati rescue nil
    title
  end

  def authors
    self.reload
    self.work.patrons if self.work
  end

  def author
    authors.collect(&:full_name) + authors.collect(&:full_name_transcription) if authors
  end

  def last_issue
    if self.serial?
      self.manifestations.find(:first, :conditions => 'date_of_publication IS NOT NULL', :order => 'date_of_publication DESC', :limit => 1)
    end
  rescue
    nil
  end

  def work_id
    self.work.id if self.work
  end

  def subscription_id
    self.subscription.id if self.subscription
  end

  def manifestation_ids
    self.manifestations.collect(&:id)
  end

  def patron_ids
    self.patrons.collect(&:id)
  end

  def expression_merge_list_ids
    self.expression_merge_lists.collect(&:id)
  end

  def subscribed?
    return true if self.subscribe.end_on > Time.zone.now
  rescue
    nil
  end

end
