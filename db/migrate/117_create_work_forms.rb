class CreateWorkForms < ActiveRecord::Migration
  def self.up
    create_table :work_forms do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :work_forms
  end
end
