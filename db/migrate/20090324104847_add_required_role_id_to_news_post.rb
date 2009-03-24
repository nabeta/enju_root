class AddRequiredRoleIdToNewsPost < ActiveRecord::Migration
  def self.up
    add_column :news_posts, :required_role_id, :integer, :default => 1, :null => false
  end

  def self.down
    remove_column :news_posts, :required_role_id
  end
end
