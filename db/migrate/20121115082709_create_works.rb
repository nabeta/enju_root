class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.text :original_title

      t.timestamps
    end
  end
end
