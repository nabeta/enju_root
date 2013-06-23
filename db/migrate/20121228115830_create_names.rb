class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.string :type_of_name
      t.string :name_string
      t.text :scope_of_usage
      t.text :dates_of_usage
      t.integer :language_id
      t.string :script
      t.string :transliteration_scheme

      t.timestamps
    end
  end
end
