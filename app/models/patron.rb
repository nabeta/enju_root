class Patron < ActiveRecord::Base
  has_one :user, :dependent => :destroy
  has_one :library, :include => :library_group
  has_many :creates, :dependent => :destroy
  has_many :works, :through => :creates, :include => :work_form, :as => :creators
  has_many :realizes, :dependent => :destroy
  has_many :expressions, :through => :realizes, :include => :expression_form
  has_many :produces, :dependent => :destroy
  has_many :manifestations, :through => :produces, :include => :manifestation_form
  has_many :owns, :dependent => :destroy
  has_many :items, :through => :owns, :include => [:use_restrictions, :circulation_status]
  #has_one :person
  #has_one :corporate_body
  #has_one :conference
  has_many :donates
  has_many :donated_items, :through => :donates, :source => :item
  belongs_to :language #, :validate => true
  belongs_to :country #, :validate => true
  has_many :patron_merges, :dependent => :destroy
  has_many :patron_merge_lists, :through => :patron_merges
  #has_many :resource_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :resource_has_subjects
  has_many :attachment_files, :as => :attachable, :dependent => :destroy
  belongs_to :patron_type #, :validate => true
  belongs_to :access_role, :class_name => 'Role', :foreign_key => 'access_role_id', :validate => true
  has_many :advertises, :dependent => :destroy
  has_many :advertisements, :through => :advertises
  #has_many :works_as_subjects, :through => :resource_has_subjects, :as => :subjects

  validates_presence_of :full_name, :language, :patron_type, :country
  validates_associated :language, :patron_type, :country

  acts_as_solr :fields => [:name, :place, :address_1, :address_2, :zip_code_1, :zip_code_2, :address_1_note, :address_2_note, :other_designation, {:created_at => :date}, {:updated_at => :date}, {:date_of_birth => :date}, {:date_of_death => :date},
    {:work_ids => :integer}, {:expression_ids => :integer}, {:manifestation_ids => :integer}, {:patron_type_id => :integer}, {:access_role_id => :range_integer}, {:patron_merge_list_ids => :integer}],
    :facets => [:patron_type_id, :date_of_birth], :if => proc{|patron| !patron.restrain_indexing}, :auto_commit => false
  acts_as_soft_deletable
  acts_as_tree

  cattr_reader :per_page
  @@per_page = 10
  attr_accessor :restrain_indexing

  def before_validation_on_create
    self.access_role = Role.find(:first, :conditions => {:name => 'Librarian'}) if self.access_role_id.nil?
  end

  #def full_name_generate
  #  # TODO: 日本人以外は？
  #  name = []
  #  name << self.last_name.to_s.strip
  #  name << self.middle_name.to_s.strip unless self.middle_name.blank?
  #  name << self.first_name.to_s.strip
  #  name << self.corporate_name.to_s.strip
  #  name.join(" ").strip
  #end

  def full_name_without_space
    full_name.gsub(/\s/, "")
  #  # TODO: 日本人以外は？
  #  name = []
  #  name << self.last_name.to_s.strip
  #  name << self.middle_name.to_s.strip
  #  name << self.first_name.to_s.strip
  #  name << self.corporate_name.to_s.strip
  #  name.join("").strip
  end

  def full_name_transcription_without_space
    self.full_name_transcription.gsub(/\s/, "")
  rescue
    nil
  end

  def name
    name = []
    name << full_name
    name << full_name_transcription
    name << full_name_alternative
    name << full_name.wakati
    name << full_name_transcription.wakati rescue nil
    name << full_name_alternative.wakati rescue nil
    name
  end

  def author?(expression)
    expression.patrons.each do |patron|
      if self == patron
        return true
      end
    end
    return nil
  end

  def publisher?(manifestation)
    manifestation.patrons.each do |patron|
      if self == patron
        return true
      end
    end
    return nil
  end

  def involved_manifestations
    involvements = []
    works.each do |work|
      involvements << work.manifestations
    end
    expressions.each do |expression|
      involvements << expression.manifestations
    end
    involvements << manifestations
    involvements.flatten.uniq
  end

  #def hidden_patron?
  #  return true if self.access_role.name == 'Librarian'
  #  return true if self.hidden
  #  false
  #end

  def check_access_role(user)
    return true if self.user.blank?
    return true if self.user.access_role.name == 'Guest'
    return true if user == self.user
    return true if user.has_role?(self.user.access_role.name)
    false
  rescue
    false
  end

  def work_ids
    self.works.collect(&:id)
  end

  def expression_ids
    self.expressions.collect(&:id)
  end

  def manifestation_ids
    self.manifestations.collect(&:id)
  end

  def patron_merge_list_ids
    self.patron_merge_lists.collect(&:id)
  end

end
