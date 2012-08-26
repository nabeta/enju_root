module PatronsHelper
  def patron_custom_book_jacket(patron)
    if picture_file = patron.picture_files.first
      if Setting.uploaded_file.storage == :s3
        render :partial => 'picture_files/link', :locals => {:picture_file => picture_file}
      else
        link_to image_tag(picture_file_path(picture_file, :format => :download, :size => 'thumb')), picture_file_path(picture_file, :format => :download), :rel => "patron_#{patron.id}"
      end
    end
  end
end
