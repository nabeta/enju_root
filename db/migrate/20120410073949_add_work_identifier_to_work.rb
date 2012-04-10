class AddWorkIdentifierToWork < ActiveRecord::Migration
  def change
    add_column :works, :work_identifier, :string
  end
end
