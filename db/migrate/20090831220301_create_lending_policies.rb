class CreateLendingPolicies < ActiveRecord::Migration
  def self.up
    create_table :lending_policies do |t|
      t.integer :item_id, :null => false
      t.integer :user_group_id, :null => false
      t.integer :loan_period
      t.datetime :fixed_due_date
      t.integer :renewal
      t.decimal :fine
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :lending_policies
  end
end
