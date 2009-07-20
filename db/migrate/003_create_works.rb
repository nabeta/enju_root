class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.integer :parent_id
      t.text :original_title, :null => false
      t.text :title_transcription
      t.text :title_alternative
      t.text :context
      t.integer :work_form_id, :default => 1, :null => false
      t.text :note
      t.integer :creates_count, :default => 0, :null => false
      t.integer :reifies_count, :default => 0, :null => false
      t.integer :resource_has_subjects_count, :default => 0, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.integer :required_role_id, :default => 1, :null => false
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.integer :medium_of_performance_id, :default => 1, :null => false
    end
    add_index :works, :work_form_id
    add_index :works, :parent_id
    add_index :works, :required_role_id
  end

  def self.down
    drop_table :works
  end
end
