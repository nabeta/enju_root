class RemoveDisplayName < ActiveRecord::Migration
  def self.up
    remove_column :checkout_types, :display_name
    remove_column :circulation_statuses, :display_name
    remove_column :classification_types, :display_name
    remove_column :countries, :display_name
    remove_column :expression_forms, :display_name
    remove_column :frequency_of_issues, :display_name
    remove_column :languages, :display_name
    remove_column :library_groups, :display_name
    remove_column :manifestation_forms, :display_name
    remove_column :patron_types, :display_name
    remove_column :request_status_types, :display_name
    remove_column :request_types, :display_name
    remove_column :roles, :display_name
    remove_column :shelves, :display_name
    remove_column :subject_heading_types, :display_name
    remove_column :subject_types, :display_name
    remove_column :use_restrictions, :display_name
    remove_column :user_groups, :display_name
    remove_column :work_forms, :display_name
  end

  def self.down
  end
end
