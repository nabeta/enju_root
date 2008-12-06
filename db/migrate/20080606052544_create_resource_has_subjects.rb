class CreateResourceHasSubjects < ActiveRecord::Migration
  def self.up
    create_table :resource_has_subjects do |t|
      t.integer :subject_id, :null => false
      t.integer :subjectable_id, :null => false
      t.string :subjectable_type, :null => false

      t.timestamps
    end
    add_index :resource_has_subjects, :subject_id
    add_index :resource_has_subjects, [:subjectable_id, :subjectable_type], :name => "index_resource_has_subjects_on_subjectable_id_and_type"
  end

  def self.down
    drop_table :resource_has_subjects
  end
end
