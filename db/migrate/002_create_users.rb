class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string :login, :null => false
      t.string :email, :string
      t.string :crypted_password, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.string :password_salt, :null => false
      t.string :persistence_token, :string, :null => false
      t.string :single_access_token, :string, :null => false
      t.string :perishable_token, :string, :null => false
      t.integer :login_count, :integer, :null => false, :default => 0
      t.integer :failed_login_count, :integer, :null => false, :default => 0
      t.datetime :last_request_at, :datetime
      t.datetime :last_login_at, :datetime
      t.datetime :current_login_at, :datetime
      t.string :last_login_ip, :string
      t.string :current_login_ip, :string

      t.integer :library_id, :default => 1, :null => false
      t.integer :user_group_id, :default => 1, :null => false
      t.integer :reserves_count, :default => 0, :null => false
      t.datetime :expired_at
      t.boolean :suspended, :default => true, :null => false
      t.integer :libraries_count, :default => 0, :null => false
      t.integer :bookmarks_count, :default => 0, :null => false
      t.integer :checkouts_count, :default => 0, :null => false
      t.string :checkout_icalendar_token
      t.integer :questions_count, :default => 0, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.string :answer_feed_token
      t.integer :due_date_reminder_days, :default => 1, :null => false
      t.text :note
      t.boolean :share_bookmarks, :default => false, :null => false
      t.boolean :save_search_history, :default => false, :null => false
      t.boolean :save_checkout_history, :default => false, :null => false
      t.integer :required_role_id, :default => 1, :null => false
      t.text :keyword_list
      t.string :user_number
      t.string :state
      t.integer :required_score, :default => 0, :null => false
      t.string :locale
    end
    add_index :users, :login, :unique => true
    add_index :users, :user_group_id
    add_index :users, :required_role_id
    add_index :users, :user_number, :unique => true
    add_index :users, :checkout_icalendar_token, :unique => true
    add_index :users, :answer_feed_token, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
