class Answer < ActiveRecord::Base
  belongs_to :user, :counter_cache => true, :validate => true
  belongs_to :question, :counter_cache => true, :validate => true

  acts_as_paranoid
  after_save :save_questions

  validates_associated :user, :question
  validates_presence_of :user, :question, :body

  cattr_reader :per_page
  @@per_page = 10

  def save_questions
    self.question.save
  end
end
