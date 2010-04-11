require 'rake'
require 'active_record/fixtures'

namespace :enju do
  desc 'Load initial database fixtures.'
  task :setup do
    require "#{File.dirname(__FILE__)}/../../config/environment.rb"
    if User.administrators.blank?
      puts 'Loading fixtures...'
      Dir.glob(Rails.root.to_s + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end
      unless solr = Sunspot.commit rescue nil
      	puts "Solr is not running."
        exit
      end

      user = User.new
      library_group = LibraryGroup.find(1)
      user.patron = Patron.find(1)
      print "Enter new administrator username: "
      user.username = $stdin.gets.chop
      email = ""; email_confirmation = nil
      while email != email_confirmation
        print "Enter new administrator email address: "
        email = $stdin.gets.chop
        print "Confirm administrator email address: "
        email_confirmation = $stdin.gets.chop
        if email != email_confirmation
          puts "Email address mismatch!"
          sleep 1
        end
      end
      user.email = email; user.email_confirmation = email

      password = ""; password_confirmation = nil
      while password != password_confirmation
        print "Enter new administrator password: "
        system "stty -echo"
        password = $stdin.gets.chop
        system "stty echo"
        puts
        print "Confirm administrator password: "
        system "stty -echo"
        password_confirmation = $stdin.gets.chop
        system "stty echo"
        puts
        if password != password_confirmation
          puts "Password mismatch!"
          sleep 1
        end
      end
      user.password = password; user.password_confirmation = password

      puts "Saving user information..."

      user.user_group = UserGroup.find(1)
      user.library = Library.find(2)
      user.user_number = '0'

      begin
        User.transaction do
      	  library_group.save
          user.locale = I18n.default_locale.to_s
      	  user.roles << Role.find_by_name('Administrator')
          user.confirm!
          user.activate
          user.save!
        end
        user.index
        puts 'Administrator account created.'
      rescue
        puts $!
        exit
      end

      Patron.reindex
      Library.reindex
      puts 'Inititalized successfully.'
    else
      puts 'It seems that you have imported initial data.'
    end
  end

end
