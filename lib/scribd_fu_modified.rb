module ScribdFuModified

  # Load, store, and return the associated iPaper document
  def load_ipaper_document(id)
    begin
      @document ||= scribd_user.find_document(id)
    rescue
      nil
      #raise ScribdFuError, "Scribd Document ##{id} not found!"
    end
  end

end

module ScribdFu::ClassMethods
  include ScribdFuModified
end
