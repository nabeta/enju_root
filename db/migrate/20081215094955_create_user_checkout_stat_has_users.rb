class CreateUserCheckoutStatHasUsers < ActiveRecord::Migration
  def self.up
    create_table :user_checkout_stat_has_users do |t|
      t.integer :user_checkout_stat_id
      t.integer :user_id
      t.integer :checkouts_count, :default => 0, :null => false

      t.timestamps
    end
    add_index :user_checkout_stat_has_users, :user_checkout_stat_id
    add_index :user_checkout_stat_has_users, :user_id
  end

  def self.down
    drop_table :user_checkout_stat_has_users
  end
end
