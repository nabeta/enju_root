class AddIdentifierToExpression < ActiveRecord::Migration
  def self.up
    add_column :expressions, :identifier, :string
  end

  def self.down
    remove_column :expressions, :identifier
  end
end
