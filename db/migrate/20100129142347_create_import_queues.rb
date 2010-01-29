class CreateImportQueues < ActiveRecord::Migration
  def self.up
    create_table :import_queues do |t|
      t.string :isbn
      t.string :state
      t.integer :manifestation_id

      t.timestamps
    end
    add_index :import_queues, :isbn
    add_index :import_queues, :manifestation_id
  end

  def self.down
    drop_table :import_queues
  end
end
