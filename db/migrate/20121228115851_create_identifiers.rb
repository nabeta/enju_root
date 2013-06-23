class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.string :type_of_identifier

      t.timestamps
    end
  end
end
