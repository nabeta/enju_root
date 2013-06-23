class AddTextbookSubjectToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :textbook_subject, :string
    add_column :manifestations, :course, :string
  end
end
