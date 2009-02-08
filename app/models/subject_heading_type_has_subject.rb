class SubjectHeadingTypeHasSubject < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :subject_heading_type

  validates_presence_of :subject, :subject_heading_type
  validates_associated :subject, :subject_heading_type

  @@per_page = 10
  cattr_reader :per_page
end
