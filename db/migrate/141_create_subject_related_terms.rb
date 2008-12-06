class CreateSubjectRelatedTerms < ActiveRecord::Migration
  def self.up
    create_table :subject_related_terms do |t|
      t.integer :subject_id, :null => false
      t.integer :related_term_id, :null => false
      t.timestamps
    end
    add_index :subject_related_terms, :subject_id
    add_index :subject_related_terms, :related_term_id
  end

  def self.down
    drop_table :subject_related_terms
  end
end
