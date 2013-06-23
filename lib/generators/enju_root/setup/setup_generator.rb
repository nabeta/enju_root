class EnjuRoot::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju Root"

  def copy_setup_files
    directory("solr", "solr")
    directory("db/fixtures", "db/fixtures/enju_root")
    copy_file("config/application.yml", "config/application.yml")
    inject_into_file "config.ru", :after => /require ::File.expand_path\(\'..\/config\/environment\',  __FILE__\)$\n/ do
      <<"EOS"
require 'rack/protection'
use Rack::Protection, :except => [:escaped_params, :json_csrf, :http_origin, :session_hijacking, :remote_token]
EOS
    end
    rake("enju_root_engine:install:migrations")
    inject_into_file "app/assets/javascripts/application.js", :after => /\/\/= require jquery_ujs$\n/ do
      "//= require enju_root/application\n"
    end
    inject_into_file "app/assets/stylesheets/application.css", :after => / *= require_self$\n/ do
      " *= require enju_root/application\n"
    end
    gsub_file 'config/routes.rb', /devise_for :users$/, "devise_for :users, :path => 'accounts'"

    generate("sunspot_rails:install")
    remove_file "public/index.html"
    remove_file "app/views/layouts/application.html.erb"
  end
end
