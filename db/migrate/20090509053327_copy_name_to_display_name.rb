class CopyNameToDisplayName < ActiveRecord::Migration
  def self.up
    models = %w(checkout_types circulation_statuses classification_types countries event_categories expression_forms frequency_of_issues languages library_groups manifestation_forms patron_types request_status_types request_types shelves subject_heading_types subject_types use_restrictions user_groups work_forms)
    models.each do |model|
      sql = "UPDATE #{model} SET display_name = name"
      execute(sql)
      change_column(model, :name, :text)
    end
  end

  def self.down
  end
end
