source 'https://rubygems.org'

ruby '1.9.3'
gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'enju_core', :git => 'git://github.com/next-l/enju_core.git'
gem 'enju_event', :git => 'git://github.com/next-l/enju_event.git'
#gem 'enju_ndl', :git => 'git://github.com/next-l/enju_ndl.git'
gem 'enju_nii', :git => 'git://github.com/next-l/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/next-l/enju_oai.git'
gem 'enju_news', :git => 'git://github.com/next-l/enju_news.git'
gem 'enju_book_jacket', :git => 'git://github.com/next-l/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/next-l/enju_manifestation_viewer.git'
gem 'enju_message', :git => 'git://github.com/next-l/enju_message.git'
gem 'enju_subject', :git => 'git://github.com/next-l/enju_subject.git'

gem 'pg'
#gem 'mysql2', '~> 0.3'
#gem 'sqlite3'
gem 'zipruby'
gem 'kgio'

gem 'levenshtein19'

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcpostgresql-adapter'
  #gem 'activerecord-jdbcmysql-adapter'
  gem 'rubyzip'
  gem 'trinidad'
end

gem 'exception_notification', '~> 3.0'
gem 'resque_mailer'
gem 'state_machine', '~> 1.1.2'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
gem 'strongbox'
gem 'dalli', '~> 2.5'
gem 'sitemap_generator', '~> 3.4'
gem 'ri_cal'
gem 'paper_trail', '~> 2.6'
gem 'RedCloth', '>= 4.2.9'
gem 'lisbn'
gem 'devise-encryptable'
gem 'addressable'
gem 'paperclip', '~> 3.4'
gem 'paperclip-meta'
gem 'aws-sdk', '~> 1.8'
gem 'whenever', :require => false
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'geocoder'
gem 'library_stdnums'
gem 'client_side_validations', '~> 3.2'
gem 'simple_form', '~> 2.0'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
gem 'strong_parameters'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem 'resque_mailer'
gem 'linkeddata'

gem 'oink', '>= 0.9.3'

group :development do
  gem 'annotate', '~> 2.5'
  gem 'progress_bar'
  gem 'sunspot_solr', '~> 2.0.0.pre.120925'
end

group :development, :test do
  gem 'ruby-prof'
  gem 'simplecov', '~> 0.7', :require => false
  gem 'rspec-rails', '~> 2.12'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'spork-rails'
#  gem 'rcov', '0.9.11'
#  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/justinko/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.3'
  gem 'fakeweb'
#  gem 'churn', '0.0.13'
  gem 'parallel_tests', '~> 0.8'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
