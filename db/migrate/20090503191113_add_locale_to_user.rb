class AddLocaleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :string
    User.find_by_sql(['UPDATE users SET locale = ?', I18n.default_locale])
  end

  def self.down
    remove_column :users, :locale
  end
end
