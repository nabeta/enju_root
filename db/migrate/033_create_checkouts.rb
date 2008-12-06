class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.column :user_id, :integer
      t.column :item_id, :integer, :null => false
      t.column :checkin_id, :integer
      t.column :librarian_id, :integer
      t.column :basket_id, :integer
      t.column :due_date, :datetime
      t.column :checkout_renewal_count, :integer, :default => 0, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :checkouts, :user_id
    add_index :checkouts, :item_id
    add_index :checkouts, :basket_id
    add_index :checkouts, [:item_id, :basket_id], :unique => true
    add_index :checkouts, :librarian_id
    add_index :checkouts, :checkin_id
  end

  def self.down
    drop_table :checkouts
  end
end
