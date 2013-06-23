class AddNoteToExpression < ActiveRecord::Migration
  def change
    add_column :expressions, :note, :text
  end
end
