$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_root/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_root"
  s.version     = EnjuRoot::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["tanabe@mwr.mediacom.keio.ac.jp"]
  s.homepage    = "https://github.com/next-l/enju_root"
  s.summary     = "Next-L Enju Root"
  s.description = "bibliographic record management system"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "enju_core", "~> 0.1.1.pre4"
  s.add_dependency "sitemap_generator"
  s.add_dependency "devise-encryptable"
  s.add_dependency "redis-rails"
  s.add_dependency "rails_autolink"
  s.add_dependency "jquery-ui-rails"
  s.add_dependency "ruby-graphviz"
  s.add_dependency "linkeddata"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "sunspot_solr"
end
