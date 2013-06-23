class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_identifier

      t.timestamps
    end
  end
end
