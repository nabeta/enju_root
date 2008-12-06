class CreateEmbodies < ActiveRecord::Migration
  def self.up
    create_table :embodies do |t|
      t.column :expression_id, :integer, :null => false
      t.column :manifestation_id, :integer, :null => false
      t.string :type
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :embodies, :expression_id
    add_index :embodies, :manifestation_id
    add_index :embodies, :type
  end

  def self.down
    drop_table :embodies
  end
end
