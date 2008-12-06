class CreateUserGroups < ActiveRecord::Migration
  def self.up
    create_table :user_groups do |t|
      t.column :name, :string
      t.column :display_name, :text
      t.column :note, :text
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :user_groups
  end
end
