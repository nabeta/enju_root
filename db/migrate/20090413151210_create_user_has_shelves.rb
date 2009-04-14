class CreateUserHasShelves < ActiveRecord::Migration
  def self.up
    create_table :user_has_shelves do |t|
      t.integer :user_id
      t.integer :shelf_id
      t.integer :position

      t.timestamps
    end
    add_index :user_has_shelves, [:user_id, :shelf_id]
  end

  def self.down
    drop_table :user_has_shelves
  end
end
