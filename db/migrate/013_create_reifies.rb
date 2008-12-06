class CreateReifies < ActiveRecord::Migration
  def self.up
    create_table :reifies do |t|
      t.column :work_id, :integer, :null => false
      t.column :expression_id, :integer, :null => false
      t.column :position, :integer
      t.column :type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :reifies, :work_id
    add_index :reifies, :expression_id
    add_index :reifies, :type
  end

  def self.down
    drop_table :reifies
  end
end
