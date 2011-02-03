class AddCompletedAtToUserCheckoutStat < ActiveRecord::Migration
  def self.up
    add_column :bookmark_stats, :started_at, :datetime
    add_column :bookmark_stats, :completed_at, :datetime
    add_index :bookmark_stats, :state
  end

  def self.down
    remove_column :bookmark_stats, :started_at
    remove_column :bookmark_stats, :completed_at
  end
end
