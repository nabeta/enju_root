class CreateControlledAccessPoints < ActiveRecord::Migration
  def change
    create_table :controlled_access_points do |t|
      t.string :type_of_controlled_access_point
      t.text :status
      t.text :designated_usage
      t.text :undifferentiated_access_point
      t.integer :base_access_point_language_id
      t.integer :cataloging_language_id
      t.text :script_of_base_access_point
      t.text :script_of_cataloging
      t.text :transliteratrion_scheme_of_base_access_point
      t.text :transliteration_scheme_of_cataloging
      t.text :source
      t.integer :base_access_point_id
      t.text :addition

      t.timestamps
    end
  end
end
