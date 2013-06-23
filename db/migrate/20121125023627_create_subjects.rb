class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :term
      t.integer :subject_heading_id
      t.integer :subject_type_id

      t.timestamps
    end
  end
end
