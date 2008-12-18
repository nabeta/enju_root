require 'rubygems'
require 'rake'
require 'rake/testtask'

begin
  gem 'rspec'
  require 'spec/rake/spectask'
  require 'spec/translator'
  require 'spec/rake/spectask'
rescue Object => e
end

Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

desc "Default Task"
#task :default => [:test]

desc 'Runs the tests'
task :test do
  ENV['RAILS_ENV'] = "test"
  require File.dirname(__FILE__) + '/config/environment'
  puts "Using " + DB
  %x(mysql -u#{MYSQL_USER} < #{File.dirname(__FILE__) + "/test/fixtures/db_definitions/mysql.sql"}) if DB == 'mysql'
  
  Rake::Task["test:migrate"].invoke
  Rake::Task[:test_units].invoke
end

if Object.const_defined?(:Spec)
  desc "Run all specs"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
else
  task :spec do
    puts
    puts "WARNING: Specs not run. To run acts_as_solr specs, you need to install the rspec gem"
    puts
  end
end


desc "Run all the tests and specs"
task :spec_and_test => [:test, :spec]

task :default => [:spec_and_test]

desc "Unit Tests"
 Rake::TestTask.new('test_units') do |t|
  t.pattern = "test/unit/*_test.rb"
  t.verbose = true
end
