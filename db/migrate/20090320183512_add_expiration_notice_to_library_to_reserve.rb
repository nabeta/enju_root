class AddExpirationNoticeToLibraryToReserve < ActiveRecord::Migration
  def self.up
    rename_column :reserves, :notified, :expiration_notice_to_patron
    add_column :reserves, :expiration_notice_to_library, :boolean
  end

  def self.down
    remove_column :reserves, :expiration_notice_to_library
    rename_column :reserves, :expiration_notice_to_patron, :notified
  end
end
