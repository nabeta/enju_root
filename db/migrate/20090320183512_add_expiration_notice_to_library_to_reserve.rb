class AddExpirationNoticeToLibraryToReserve < ActiveRecord::Migration
  def self.up
    add_column :reserves, :expiration_notice_to_patron, :boolean, :default => false
    add_column :reserves, :expiration_notice_to_library, :boolean, :default => false
  end

  def self.down
    remove_column :reserves, :expiration_notice_to_patron
    remove_column :reserves, :expiration_notice_to_library
  end
end
