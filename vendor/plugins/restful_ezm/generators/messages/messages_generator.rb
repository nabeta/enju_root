class MessagesGenerator < Rails::Generator::NamedBase
 
  def initialize(args, options = {})
    super
    # do any needed initializations here
  end
 
  def manifest
    record do |m|
      # Controller
      m.file "messages_controller.rb", "app/controllers/messages_controller.rb" 
      
      # Helper
      m.file "messages_helper.rb", "app/helpers/messages_helper.rb"
      
      # Model
      m.file "message.rb", "app/models/message.rb"
            
      # Views
      m.directory "app/views/messages"
      m.file "index.atom.builder", "app/views/messages/index.atom.builder"
      
      if file_name == "haml"
        m.file "index.haml", "app/views/messages/index.haml"
        m.file "new.haml",   "app/views/messages/new.haml"
        m.file "show.haml",  "app/views/messages/show.haml"
      else
        m.file "index.html.erb",     "app/views/messages/index.html.erb"
        m.file "new.html.erb",       "app/views/messages/new.html.erb"
        m.file "show.html.erb",      "app/views/messages/show.html.erb" 
      end
      
      # Lib
      m.file "restful_easy_messages_controller_system.rb", "lib/restful_easy_messages_controller_system.rb"
      
      # Public
      m.file "403.html", "public/403.html"
      
      # Tests
      m.file "messages.yml",                "test/fixtures/messages.yml"
      m.file "users.yml",                   "test/fixtures/users.yml"
      m.file "messages_controller_test.rb", "test/functional/messages_controller_test.rb"
      m.file "message_test.rb",             "test/unit/message_test.rb"   
      
      # Migration
      m.migration_template 'create_restful_easy_messages.rb', 'db/migrate', :assigns => {
        :migration_name => "CreateRestfulEasyMessages"
      }, :migration_file_name => "create_restful_easy_messages"
      
    end
  end 
 
end