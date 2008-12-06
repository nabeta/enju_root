class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string, :null => false
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :openid_url,                :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :deleted_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime

      t.column :patron_id, :integer, :null => false
      t.column :library_id, :integer, :default => 1, :null => false
      t.column :user_group_id, :integer, :default => 1, :null => false
      t.column :reserves_count, :integer, :default => 0, :null => false
      t.column :expired_at, :datetime
      t.column :locked, :boolean, :default => true, :null => false
      t.column :libraries_count, :integer, :default => 0, :null => false
      t.column :bookmarks_count, :integer, :default => 0, :null => false
      t.column :checkouts_count, :integer, :default => 0, :null => false
      t.column :checkout_icalendar_token, :string
      t.column :questions_count, :integer, :default => 0, :null => false
      t.column :answers_count, :integer, :default => 0, :null => false
      t.column :answer_rss_token, :string
      t.column :duedate_reminder_days, :integer, :default => 1, :null => false
      t.column :note, :text
      t.column :share_bookmarks, :boolean, :default => false, :null => false
      t.column :save_search_history, :boolean, :default => false, :null => false
      t.column :save_checkout_history, :boolean, :default => false, :null => false
      t.column :lock_version, :integer, :default => 0, :null => false
      t.integer :access_role_id, :null => false
      t.text :keyword_list
      t.string :user_number
      t.string :state, :default => 'pending', :null => false
    end
    add_index :users, :login, :unique => true
    add_index :users, :openid_url

    add_index :users, :patron_id, :unique => true
    add_index :users, :user_group_id
    add_index :users, :access_role_id
    add_index :users, :user_number, :unique => true
    add_index :users, :checkout_icalendar_token, :unique => true
    add_index :users, :answer_rss_token, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
