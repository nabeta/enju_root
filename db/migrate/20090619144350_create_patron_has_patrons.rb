class CreatePatronHasPatrons < ActiveRecord::Migration
  def self.up
    create_table :patron_has_patrons do |t|
      t.integer :from_patron_id
      t.integer :to_patron_id
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :patron_has_patrons, :from_patron_id
    add_index :patron_has_patrons, :to_patron_id
    add_index :patron_has_patrons, :type
  end

  def self.down
    drop_table :patron_has_patrons
  end
end
