class CreateCorporateBodies < ActiveRecord::Migration
  def change
    create_table :corporate_bodies do |t|
      t.text :place_associated
      t.text :date_associated
      t.integer :language_id
      t.text :address
      t.text :field_of_activity
      t.text :history
      t.text :other_information

      t.timestamps
    end
  end
end
