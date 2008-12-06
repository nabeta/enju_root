class CreateProduces < ActiveRecord::Migration
  def self.up
    create_table :produces do |t|
      t.column :patron_id, :integer, :null => false
      t.column :manifestation_id, :integer, :null => false
      t.column :position, :integer
      t.column :type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :produces, :patron_id
    add_index :produces, :manifestation_id
    add_index :produces, :type
  end

  def self.down
    drop_table :produces
  end
end
