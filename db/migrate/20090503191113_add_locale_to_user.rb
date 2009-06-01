class AddLocaleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :locale, :string
    if User.find(:first)
      User.find_by_sql(['UPDATE users SET locale = ?', I18n.default_locale])
    end
  end

  def self.down
    remove_column :users, :locale
  end
end
