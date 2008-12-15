class CreateUserStatHasCheckouts < ActiveRecord::Migration
  def self.up
    create_table :user_stat_has_checkouts do |t|
      t.integer :user_stat_id
      t.integer :user_id
      t.integer :checkouts_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :user_stat_has_checkouts, :user_stat_id
    add_index :user_stat_has_checkouts, :user_id
  end

  def self.down
    drop_table :user_stat_has_checkouts
  end
end
