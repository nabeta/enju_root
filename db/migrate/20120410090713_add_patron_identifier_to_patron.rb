class AddPatronIdentifierToPatron < ActiveRecord::Migration
  def change
    add_column :patrons, :patron_identifier, :string
  end
end
