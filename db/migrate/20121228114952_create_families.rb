class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.integer :name_id
      t.integer :identifier_id
      t.text :type_of_family
      t.text :dates
      t.text :places_associated
      t.text :field_of_activity
      t.text :history

      t.timestamps
    end
  end
end
