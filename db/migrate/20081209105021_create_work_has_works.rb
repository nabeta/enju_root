class CreateWorkHasWorks < ActiveRecord::Migration
  def self.up
    create_table :work_has_works do |t|
      t.integer :from_work_id
      t.integer :to_work_id
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :work_has_works, :from_work_id
    add_index :work_has_works, :to_work_id
    add_index :work_has_works, :type
  end

  def self.down
    drop_table :work_has_works
  end
end
