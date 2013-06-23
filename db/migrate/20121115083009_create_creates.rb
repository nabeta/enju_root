class CreateCreates < ActiveRecord::Migration
  def change
    create_table :creates do |t|
      t.references :work
      t.references :person

      t.timestamps
    end
    add_index :creates, :work_id
    add_index :creates, :person_id
  end
end
