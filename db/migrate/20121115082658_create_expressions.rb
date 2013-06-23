class CreateExpressions < ActiveRecord::Migration
  def change
    create_table :expressions do |t|
      t.text :original_title
      t.references :content_type

      t.timestamps
    end
    add_index :expressions, :content_type_id
  end
end
