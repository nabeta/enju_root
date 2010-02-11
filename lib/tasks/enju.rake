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
      library_group = LibraryGroup.find(1)
      user.patron = Patron.find(1)
      print "Enter new administrator login name: "
      user.login = $stdin.gets.chop
      print "Enter new administrator email address: "
      user.email = $stdin.gets.chop
      library_group.email = user.email
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
      user.library = Library.find(2)
      user.user_number = '0'

      begin
        User.transaction do
      	  library_group.save
      	  user.roles << Role.find_by_name('Administrator')
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

  desc 'Rebuild solr index.'
  task :reindex do
    %w(Advertisement Bookmark Classification Event Expression Item Manifestation Message Patron PurchaseRequest Question Subject Subscription Tag User Work).each do |class_name|
      Object.const_get(class_name).reindex(:batch_commit => false)
    end
  end

end
