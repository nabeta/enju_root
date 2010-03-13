class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.string :iss_token
      t.integer :manifestation_id
      t.text :dcndl_xml
      t.string :work_token
      t.datetime :deleted_at
      t.boolean :approved
      t.string :state

      t.timestamps
    end
    add_index :resources, :iss_token
    add_index :resources, :manifestation_id
    add_index :resources, :work_token
  end

  def self.down
    drop_table :resources
  end
end
