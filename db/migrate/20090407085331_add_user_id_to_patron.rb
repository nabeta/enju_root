class AddUserIdToPatron < ActiveRecord::Migration
  def self.up
    add_column :patrons, :user_id, :integer
    User.find(:all).each do |user|
      if user.patron_id
        Patron.find_by_sql(['UPDATE patrons SET user_id = ? WHERE id = ?', user.id, user.patron_id])
      end
    end
    add_index :patrons, :user_id
    remove_column :users, :patron_id
  end

  def self.down
    add_column :users, :patron_id, :integer
    Patron.find(:all).each do |patron|
      if patron.user_id
        User.find_by_sql(['UPDATE users SET patron_id = ? WHERE id = ?', patron.id, patron.user_id])
      end
    end
    remove_column :users, :patron_id
  end
end
