class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.column :user_id, :integer
      t.column :question_id, :integer
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
    add_index :answers, :user_id
    add_index :answers, :question_id
  end

  def self.down
    drop_table :answers
  end
end
