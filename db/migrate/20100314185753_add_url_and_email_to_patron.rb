class AddUrlAndEmailToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :email, :text
    add_column :patrons, :url, :text
  end

  def self.down
    remove_column :patrons, :url
    remove_column :patrons, :email
  end
end
