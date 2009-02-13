class Answer < ActiveRecord::Base
  named_scope :public_answers, :conditions => {:shared => true}
  named_scope :private_answers, :conditions => {:shared => false}
  belongs_to :user, :counter_cache => true, :validate => true
  belongs_to :question, :counter_cache => true, :validate => true

  acts_as_soft_deletable
  after_save :save_questions

  validates_associated :user, :question
  validates_presence_of :user, :question, :body

  cattr_reader :per_page
  @@per_page = 10

  def save_questions
    self.question.save
  end
end
