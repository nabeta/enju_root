class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.column :user_id, :integer
      t.column :body, :text
      t.column :private_question, :boolean, :default => true, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
    add_index :questions, :user_id
  end

  def self.down
    drop_table :questions
  end
end
