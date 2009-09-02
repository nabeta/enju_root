class Patron < ActiveRecord::Base
  include LibrarianOwnerRequired
  include EnjuFragmentCache
  include SolrIndex

  belongs_to :user #, :validate => true
  has_one :library
  has_many :creates, :dependent => :destroy
  has_many :works, :through => :creates, :as => :creators
  has_many :realizes, :dependent => :destroy
  has_many :expressions, :through => :realizes
  has_many :produces, :dependent => :destroy
  has_many :manifestations, :through => :produces
  has_many :owns, :dependent => :destroy
  has_many :items, :through => :owns
  #has_one :person
  #has_one :corporate_body
  #has_one :conference
  has_many :donates
  has_many :donated_items, :through => :donates, :source => :item
  belongs_to :language #, :validate => true
  belongs_to :country #, :validate => true
  has_many :patron_merges, :dependent => :destroy
  has_many :patron_merge_lists, :through => :patron_merges
  #has_many :work_has_subjects, :as => :subjectable, :dependent => :destroy
  #has_many :subjects, :through => :work_has_subjects
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :patron_type #, :validate => true
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_many :advertises, :dependent => :destroy
  has_many :advertisements, :through => :advertises
  has_many :participates, :dependent => :destroy
  has_many :events, :through => :participates
  #has_many :works_as_subjects, :through => :work_has_subjects, :as => :subjects
  has_many :to_patrons, :foreign_key => 'from_patron_id', :class_name => 'PatronHasPatron', :dependent => :destroy
  has_many :from_patrons, :foreign_key => 'to_patron_id', :class_name => 'PatronHasPatron', :dependent => :destroy
  has_many :derived_patrons, :through => :to_patrons, :source => :to_patron
  has_many :original_patrons, :through => :from_patrons, :source => :from_patron

  validates_presence_of :full_name, :language, :patron_type, :country
  validates_associated :language, :patron_type, :country
  validates_length_of :full_name, :maximum => 255

  searchable :auto_index => false do
    text :name, :place, :address_1, :address_2, :other_designation
    string :zip_code_1
    string :zip_code_2
    string :login do
      user.login if user
    end
    time :created_at
    time :updated_at
    time :date_of_birth
    time :date_of_death
    string :user
    integer :work_ids, :multiple => true
    integer :expression_ids, :multiple => true
    integer :manifestation_ids, :multiple => true
    integer :patron_merge_list_ids, :multiple => true
    integer :original_patron_ids, :multiple => true
    integer :required_role_id
    integer :patron_type_id
  end

  #acts_as_soft_deletable
  #acts_as_tree

  cattr_accessor :per_page
  @@per_page = 10
  attr_accessor :user_id

  def before_validation_on_create
    self.required_role = Role.find(:first, :conditions => {:name => 'Librarian'}) if self.required_role_id.nil?
    if self.full_name.blank?
      self.full_name = [last_name, middle_name, first_name].split(" ").to_s
    end
    if self.full_name_transcription.blank?
      self.full_name_transcription = [last_name_transcription, middle_name_transcription, first_name_transcription].split(" ").to_s
    end
  end

  def after_save
    send_later(:index!)
  end

  def after_destroy
    send_later(:remove_from_index!)
  end

  def full_name
    if self[:full_name].to_s.strip.blank?
      if FAMILY_NAME_FIRST == true
        "#{self.last_name} #{self.first_name}"
      else
        "#{self.first_name} #{self.last_name}"
      end
    else
      self[:full_name]
    end
  end

  def full_name_transcription
    if self[:full_name_transcription].to_s.strip.blank?
      if FAMILY_NAME_FIRST == true
        "#{self.last_name_transcription} #{self.first_name_transcription}"
      else
        "#{self.first_name_transcription} #{self.last_name_transcription}"
      end
    else
      self[:full_name_transcription]
    end
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

  def full_name_alternative_without_space
    self.full_name_alternative.gsub(/\s/, "")
  rescue
    nil
  end

  def name
    name = []
    name << full_name
    name << full_name_transcription
    name << full_name_alternative
    #name << full_name_without_space
    #name << full_name_transcription_without_space
    #name << full_name_alternative_without_space
    #name << full_name.wakati rescue nil
    #name << full_name_transcription.wakati rescue nil
    #name << full_name_alternative.wakati rescue nil
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
  #  return true if self.required_role.name == 'Librarian'
  #  return true if self.hidden
  #  false
  #end

  def check_required_role(user)
    return true if self.user.blank?
    return true if self.user.required_role.name == 'Guest'
    return true if user == self.user
    return true if user.has_role?(self.user.required_role.name)
    false
  rescue
    false
  end

  def self.is_creatable_by(user, parent = nil)
    #true if user.has_role?('Librarian')
    true if user.has_role?('User')
  rescue
    false
  end

  def is_readable_by(user, parent = nil)
    # TODO: role id を使わない制御
    true if self.required_role.id == 1 || user.highest_role.id >= self.required_role.id || user == self.user
  rescue
    false
  end

  def is_updatable_by(user, parent = nil)
    if user and user == self.user
      return true
    end
    if self.user
      if self.user.has_role?('Librarian')
        return true if user.has_role?('Administrator')
      elsif self.user.has_role?('User')
        return true if user.has_role?('Librarian')
      end
    else
      return true if user.has_role?('Librarian')
    end
  rescue
    false
  end

  def is_deletable_by(user, parent = nil)
    true if user.has_role?('Librarian')
  rescue
    false
  end

end
