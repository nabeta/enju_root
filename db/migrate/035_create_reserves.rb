class CreateReserves < ActiveRecord::Migration
  def self.up
    create_table :reserves do |t|
      t.column :user_id, :integer, :null => false
      t.column :manifestation_id, :integer, :null => false
      t.column :item_id, :integer
      t.column :request_status_type_id, :integer, :null => false
      t.column :checked_out_at, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :canceled_at, :datetime
      t.column :expired_at, :datetime
      t.column :deleted_at, :datetime
      t.string :state, :default => 'pending', :null => false
    end

    add_index :reserves, :user_id
    add_index :reserves, :manifestation_id
    add_index :reserves, :item_id
    add_index :reserves, :request_status_type_id
  end

  def self.down
    drop_table :reserves
  end
end
