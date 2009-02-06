class CreateResourceHasSubjects < ActiveRecord::Migration
  def self.up
    create_table :resource_has_subjects do |t|
      t.integer :subject_id
      t.integer :subject_type
      t.integer :work_id, :null => false

      t.timestamps
    end
    add_index :resource_has_subjects, :subject_id
    add_index :resource_has_subjects, :work_id
  end

  def self.down
    drop_table :resource_has_subjects
  end
end
