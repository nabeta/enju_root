class AddLoginBannerToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :login_banner, :text
  end

  def self.down
    remove_column :library_groups, :login_banner
  end
end
