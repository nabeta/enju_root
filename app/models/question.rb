# -*- encoding: utf-8 -*-
require 'timeout'
class Question < ActiveRecord::Base
  include LibrarianOwnerRequired
  named_scope :public_questions, :conditions => {:shared => true}
  named_scope :private_questions, :conditions => {:shared => false}
  belongs_to :user, :counter_cache => true, :validate => true
  has_many :answers

  validates_associated :user
  validates_presence_of :user, :body
  #acts_as_soft_deletable
  searchable do
    text :body, :answer_body
    string :login
    time :created_at
    time :updated_at
    boolean :shared
  end

  enju_porta
 
  cattr_accessor :per_page
  @@per_page = 10
  cattr_reader :crd_per_page
  @@crd_per_page = 5

  def answer_body
    text = ""
    self.reload
    self.answers.each do |answer|
      text += answer.body
    end
    return text
  end

  def login
    self.user.login
  end

  def is_readable_by(user, parent = nil)
    true if user == self.user || self.shared? || user.has_role?('Librarian')
  rescue
    false
  end

end
