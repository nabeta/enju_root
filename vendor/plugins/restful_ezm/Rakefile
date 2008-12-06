require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Restful_Easy_Messages plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the Test the Restful_Easy_Messages plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Restful_Easy_Messages'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('../../../app/controllers/messages_controller.rb')
  rdoc.rdoc_files.include('../../../app/helpers/messages_helper.rb')
  rdoc.rdoc_files.include('../../../app/models/message.rb')
  rdoc.rdoc_files.include('../../../test/functional/messages_controller_test.rb')
  rdoc.rdoc_files.include('../../../test/unit/message_test.rb')
end
