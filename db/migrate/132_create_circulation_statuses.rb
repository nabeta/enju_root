class CreateCirculationStatuses < ActiveRecord::Migration
  def self.up
    create_table :circulation_statuses do |t|
      t.string :name, :null => false
      t.string :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :circulation_statuses
  end
end
