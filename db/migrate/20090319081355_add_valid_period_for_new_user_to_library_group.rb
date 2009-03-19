class AddValidPeriodForNewUserToLibraryGroup < ActiveRecord::Migration
  def self.up
    add_column :library_groups, :valid_period_for_new_user, :integer, :default => 365
  end

  def self.down
    remove_column :library_groups, :valid_period_for_new_user
  end
end
