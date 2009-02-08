class SubjectHeadingType < ActiveRecord::Base
  include DisplayName
  has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :subject_heading_type_has_subjects

  validates_presence_of :name

  acts_as_list

end
