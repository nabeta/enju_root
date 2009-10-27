class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  belongs_to :tagger, :polymorphic => true
  validates_presence_of :context
end

