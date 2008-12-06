require 'rubygems'

task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles('catalog', Dir.glob("{app,config,lib}/**/*.{rb,rhtml,erb}"), 'catalog 1.0.0')
end

task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, 'po', 'locale')
end
