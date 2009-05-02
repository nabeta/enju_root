require 'rake'
require 'active_record/fixtures'
require "#{File.dirname(__FILE__)}/../../config/environment.rb"

namespace :enju do
  desc 'Load initial database fixtures.'
  task :setup do
    if User.administrators.blank?
      puts 'Loading fixtures...'
      Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
        Fixtures.create_fixtures('db/fixtures', File.basename(file, '.*'))
      end

      user = User.new
      user.patron = Patron.find(1)
      print "Enter new administrator login name: "
      user.login = $stdin.gets.chop
      print "Enter new administrator email address: "
      user.email = $stdin.gets.chop
      print "Enter new administrator password: "
      system "stty -echo"
      user.password = $stdin.gets.chop
      system "stty echo"
      puts
      print "Confirm administrator password: "
      system "stty -echo"
      user.password_confirmation = $stdin.gets.chop
      system "stty echo"
      puts
      if user.password != user.password_confirmation
        puts "Password mismatch!"
        exit
      end
      puts "Saving user information..."

      user.user_group = UserGroup.find(1)
      user.library = Library.web
      user.user_number = '0'
      user.roles << Role.find_by_name('Administrator')
      #user.indexing = true

      begin
        user.activate
        user.save!
        puts 'Administrator account created.'
      rescue
        puts $!
        exit
      end

      puts 'Inititalized successfully.'
    else
      puts 'It seems that you have imported initial data.'
    end
  end

  desc 'Expire sessions.'
  task :expire_session do
    expire_sessions(1.week.from_now)
    puts "expired sessions!"
  end

end