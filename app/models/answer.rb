# -*- encoding: utf-8 -*-
class Answer < ActiveRecord::Base
  named_scope :public_answers, :conditions => {:shared => true}
  named_scope :private_answers, :conditions => {:shared => false}
  belongs_to :user, :counter_cache => true, :validate => true
  belongs_to :question, :counter_cache => true, :validate => true
  has_many :answer_has_items, :dependent => :destroy
  has_many :items, :through => :answer_has_items

  #acts_as_soft_deletable
  after_save :save_questions
  before_save :add_items

  validates_associated :user, :question
  validates_presence_of :user_id, :question_id, :body

  def self.per_page
    10
  end

  def save_questions
    self.question.save
  end

  def self.is_indexable_by(user, parent = nil)
  #  if user.try(:has_role?, 'User')
      true
  #  else
  #    false
  #  end
  end

  def is_readable_by(user, parent = nil)
    true if user == self.user || self.shared? || user.has_role?('Librarian')
  rescue
    false
  end

  def add_items
    item_lists = item_identifier_list.to_s.strip.split.map{|i| Item.first(:conditions => {:item_identifier => i})}.compact
    self.items = item_lists
  end

end
