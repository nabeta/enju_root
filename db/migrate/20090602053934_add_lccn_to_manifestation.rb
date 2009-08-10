class AddLccnToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :lccn, :string
    add_index :manifestations, :lccn
  end

  def self.down
    remove_column :manifestations, :lccn
  end
end
