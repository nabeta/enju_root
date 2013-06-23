class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, :null => false
      t.string :native_name
      t.text :display_name
      t.string :iso_639_1
      t.string :iso_639_2
      t.string :iso_639_3
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
