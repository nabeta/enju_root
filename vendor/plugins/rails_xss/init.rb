begin
  require 'erubis/helpers/rails_helper'
  require 'rails_xss'

  Erubis::Helpers::RailsHelper.engine_class = RailsXss::Erubis
  Erubis::Helpers::RailsHelper.show_src = false

  Module.class_eval do
    include RailsXss::SafeHelpers
  end

  require 'rails_xss_helper'
  require 'av_patch'
rescue LoadError => e
  puts "Could not load all modules required by rails_xss. Please make sure erubis is installed an try again."
  raise e
end unless $gems_rake_task
