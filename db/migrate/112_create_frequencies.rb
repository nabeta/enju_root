class CreateFrequencies < ActiveRecord::Migration
  def self.up
    create_table :frequencies do |t|
      t.string :name
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :frequencies
  end
end