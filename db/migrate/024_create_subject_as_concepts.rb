class CreateSubjectAsConcepts < ActiveRecord::Migration
  def self.up
    create_table :subject_as_concepts do |t|
      t.column :term, :text
    end
  end

  def self.down
    drop_table :subject_as_concepts
  end
end
