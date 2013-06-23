class AddUsedYearToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :bib_id, :string
    add_column :manifestations, :edition, :string
    add_column :manifestations, :source_year, :integer
    add_column :manifestations, :start_year, :integer
    add_column :manifestations, :end_year, :integer
    add_column :manifestations, :examined_year, :integer
    add_column :manifestations, :textbook_code, :string
    add_column :manifestations, :textbook_number, :integer
    add_column :manifestations, :extent, :string
    add_column :manifestations, :note, :text
    add_index :manifestations, :bib_id
  end
end
