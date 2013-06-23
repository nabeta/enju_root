class RenameManifestation < ActiveRecord::Migration
  def up
    rename_column :manifestations, :original_title, :title_proper
  end

  def down
    rename_column :manifestations, :title_proper, :original_title
  end
end
