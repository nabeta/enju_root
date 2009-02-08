class CreateSubjectHeadingTypeHasSubjects < ActiveRecord::Migration
  def self.up
    create_table :subject_heading_type_has_subjects do |t|
      t.integer :subject_id
      t.string :subject_type
      t.integer :subject_heading_type_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :subject_heading_type_has_subjects
  end
end
