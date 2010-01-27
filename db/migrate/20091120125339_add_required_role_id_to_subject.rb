class AddRequiredRoleIdToSubject < ActiveRecord::Migration
  def self.up
    add_column :subjects, :required_role_id, :integer, :default => 1, :null => false
    rename_column :subjects, :resource_has_subjects_count, :work_has_subjects_count
  end

  def self.down
    remove_column :subjects, :required_role_id
    rename_column :subjects, :work_has_subjects_count, :resource_has_subjects_count
  end
end
