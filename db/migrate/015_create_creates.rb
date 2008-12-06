class CreateCreates < ActiveRecord::Migration
  def self.up
    create_table :creates do |t|
      t.column :patron_id, :integer, :null => false
      t.column :work_id, :integer, :null => false
      t.column :position, :integer
      t.column :type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :creates, :patron_id
    add_index :creates, :work_id
    add_index :creates, :type
  end

  def self.down
    drop_table :creates
  end
end
