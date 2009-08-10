class CreateSubscribes < ActiveRecord::Migration
  def self.up
    create_table :subscribes do |t|
      t.integer :subscription_id, :null => false
      t.integer :manifestation_id, :null => false
      t.date :start_on, :null => false
      t.date :end_on, :null => false

      t.timestamps
    end
    add_index :subscribes, :subscription_id
    add_index :subscribes, :manifestation_id
  end

  def self.down
    drop_table :subscribes
  end
end
