class CreateProduces < ActiveRecord::Migration
  def change
    create_table :produces do |t|
      t.references :manifestation
      t.references :person

      t.timestamps
    end
    add_index :produces, :manifestation_id
    add_index :produces, :person_id
  end
end
