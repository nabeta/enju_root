class CreateRealizes < ActiveRecord::Migration
  def change
    create_table :realizes do |t|
      t.references :expression
      t.references :person

      t.timestamps
    end
    add_index :realizes, :expression_id
    add_index :realizes, :person_id
  end
end
