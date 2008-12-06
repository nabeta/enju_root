Gem::Specification.new do |s|
  s.name = 'acts_as_paranoid'
  s.version = '1.3'
  s.date = '2008-07-17'
  
  s.summary = "Allows ActiveRecord models to delete, without actually deleting."
  s.description = "Overrides some basic methods for the current model so that calling #destroy sets a 'deleted_at' field to the current timestamp.  ActiveRecord is required."
  
  s.authors = ['Rick Olson']
  s.email = 'rick@activereload.com'
  s.homepage = 'http://github.com/technoweenie/acts_as_paranoid'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'activerecord', ['>= 2.1']
  
  s.files = ["CHANGELOG",
             "MIT-LICENSE",
             "README",
             "RUNNING_UNIT_TESTS",
             "Rakefile",
             "acts_as_paranoid.gemspec",
             "init.rb",
             "rails/init.rb",
             "lib/caboose/acts/belongs_to_with_deleted_association.rb",
             "lib/caboose/acts/has_many_through_without_deleted_association.rb",
             "lib/caboose/acts/paranoid.rb",
             "lib/acts_as_paranoid.rb"]


  s.test_files =["test/database.yml",
                 "test/fixtures/categories.yml",
                 "test/fixtures/categories_widgets.yml",
                 "test/fixtures/taggings.yml",
                 "test/fixtures/tags.yml",
                 "test/fixtures/widgets.yml",
                 "test/paranoid_test.rb",
                 "test/schema.rb",
                 "test/test_helper.rb"]

end