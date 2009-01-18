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

      t.integer :patron_id, :null => false
      t.integer :library_id, :default => 1, :null => false
      t.integer :user_group_id, :default => 1, :null => false
      t.integer :reserves_count, :default => 0, :null => false
      t.datetime :expired_at
      t.boolean :locked, :default => true, :null => false
      t.integer :libraries_count, :default => 0, :null => false
      t.integer :bookmarks_count, :default => 0, :null => false
      t.integer :checkouts_count, :default => 0, :null => false
      t.string :checkout_icalendar_token
      t.integer :questions_count, :default => 0, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.string :answer_rss_token
      t.integer :due_date_reminder_days, :default => 1, :null => false
      t.text :note
      t.boolean :share_bookmarks, :default => false, :null => false
      t.boolean :save_search_history, :default => false, :null => false
      t.boolean :save_checkout_history, :default => false, :null => false
      t.integer :lock_version, :default => 0, :null => false
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
