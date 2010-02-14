class AddSolvedToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :solved, :boolean, :null => false
    add_column :questions, :note, :text
    change_column_default :questions, :solved, false
  end

  def self.down
    remove_column :questions, :note
    remove_column :questions, :solved
  end
end
