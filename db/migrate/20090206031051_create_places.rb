class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.text :term
      t.text :note
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.string :state
      t.integer :required_score

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
