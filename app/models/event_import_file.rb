# == Schema Information
#
# Table name: event_import_files
#
#  id                        :integer          not null, primary key
#  parent_id                 :integer
#  filename                  :string(255)
#  content_type              :string(255)
#  size                      :integer
#  file_hash                 :string(255)
#  user_id                   :integer
#  note                      :text
#  executed_at               :datetime
#  state                     :string(255)
#  event_import_file_name    :string(255)
#  event_import_content_type :string(255)
#  event_import_file_size    :integer
#  event_import_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_import_fingerprint  :string(255)
#  edit_mode                 :string(255)
#  error_message             :text
#

class EventImportFile < ActiveRecord::Base
  attr_accessible :event_import, :edit_mode
  include ImportFile
  default_scope :order => 'event_import_files.id DESC'
  scope :not_imported, where(:state => 'pending')
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if configatron.uploaded_file.storage == :s3
    has_attached_file :event_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :s3_permissions => :private
  else
    has_attached_file :event_import,
      :path => ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :event_import, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values', 'application/octet-stream']
  validates_attachment_presence :event_import
  belongs_to :user, :validate => true
  has_many :event_import_results

  state_machine :initial => :pending do
    event :sm_start do
      transition [:pending, :started] => :started
    end

    event :sm_complete do
      transition :started => :completed
    end

    event :sm_fail do
      transition :started => :failed
    end

    before_transition any => :started do |patron_import_file|
      patron_import_file.executed_at = Time.zone.now
    end

    before_transition any => :completed do |patron_import_file|
      patron_import_file.error_message = nil
    end
  end

  def import_start
    executed_at = Time.zone.now
    sm_start!
    case edit_mode
    when 'create'
      import
    when 'update'
      modify
    when 'destroy'
      remove
    else
      import
    end
  end

  def import
    self.reload
    num = {:imported => 0, :failed => 0}
    rows = open_import_file
    check_field(rows.first)
    row_num = 2

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      event_import_result = EventImportResult.new
      event_import_result.assign_attributes({:event_import_file_id => id, :body => row.fields.join("\t")}, :as => :admin)
      event_import_result.save!

      event = Event.new
      event.name = row['name'].to_s.strip
      event.note = row['note']
      event.start_at = row['start_at']
      event.end_at = row['end_at']
      category = row['category'].to_s.strip
      if row['all_day'].to_s.strip.downcase == 'false'
        event.all_day = false
      else
        event.all_day = true
      end
      library = Library.where(:name => row['library']).first
      library = Library.web if library.blank?
      event.library = library
      event_category = EventCategory.where(:name => category).first || EventCategory.where(:name => 'unknown').first
      event.event_category = event_category

      if event.save!
        event_import_result.event = event
        num[:imported] += 1
        if row_num % 50 == 0
          Sunspot.commit
          GC.start
        end
      end
      event_import_result.save!
      row_num += 1
    end
    Sunspot.commit
    rows.close
    sm_complete!
    return num
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def modify
    sm_start!
    rows = open_import_file
    check_field(rows.first)
    row_num = 2

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      event = Event.find(row['id'].to_s.strip)
      event_category = EventCategory.where(:name => row['category'].to_s.strip).first
      event.event_category = event_category if event_category
      library = Library.where(:name => row['library'].to_s.strip).first
      event.library = library if library
      event.name = row['name'] if row['name'].to_s.strip.present?
      event.start_at = row['start_at'] if row['start_at'].to_s.strip.present?
      event.end_at = row['end_at'] if row['end_at'].to_s.strip.present?
      event.note = row['end_at'] if row['note'].to_s.strip.present?
      if row['all_day'].to_s.strip.downcase == 'false'
        event.all_day = false
      else
        event.all_day = true
      end
      event.save!
      row_num += 1
    end
    sm_complete!
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def remove
    sm_start!
    rows = open_import_file
    rows.shift
    row_num = 2

    rows.each do |row|
      next if row['dummy'].to_s.strip.present?
      event = Event.find(row['id'].to_s.strip)
      event.destroy
      row_num += 1
    end
    sm_complete!
  rescue => e
    self.error_message = "line #{row_num}: #{e.message}"
    sm_fail!
    raise e
  end

  def self.import
    EventImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue
    Rails.logger.info "#{Time.zone.now} importing events failed!"
  end

  private
  def open_import_file
    tempfile = Tempfile.new('event_import_file')
    if configatron.uploaded_file.storage == :s3
      uploaded_file_path = event_import.expiring_url(10)
    else
      uploaded_file_path = event_import.path
    end
    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    file = CSV.open(tempfile, :col_sep => "\t")
    header = file.first
    rows = CSV.open(tempfile, :headers => header, :col_sep => "\t")
    event_import_result = EventImportResult.new
    event_import_result.assign_attributes({:event_import_file_id => id, :body => header.join("\t")}, :as => :admin)
    event_import_result.save!
    tempfile.close(true)
    file.close
    rows
  end

  def check_field(field)
    if [field['name']].reject{|f| f.to_s.strip == ""}.empty?
      raise "You should specify a name in the first line"
    end
    if [field['start_at'], field['end_at']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify dates in the first line"
    end
  end
end
