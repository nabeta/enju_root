class SubjectBroaderTerm < ActiveRecord::Base
  belongs_to :narrower_term, :class_name => 'Subject', :foreign_key => 'narrower_term_id', :validate => true
  belongs_to :broader_term, :class_name => 'Subject', :foreign_key => 'broader_term_id', :validate => true
end
