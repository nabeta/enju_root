module DateTimeTextFieldHelpers
  module FormHelpers

    def date_text_field(object_name, method, options = {})
      args = [object_name, method, self, options.delete(:object)]
      args.insert(3, nil) if Rails::VERSION::STRING < '2.2'
      ActionView::Helpers::InstanceTag.new(*args).to_date_text_field_tag(options)
    end
    
    def time_text_field(object_name, method, options = {})
      args = [object_name, method, self, options.delete(:object)]
      args.insert(3, nil) if Rails::VERSION::STRING < '2.2'
      ActionView::Helpers::InstanceTag.new(*args).to_time_text_field_tag(options)
    end
    
    def datetime_text_field(object_name, method, options = {})
      args = [object_name, method, self, options.delete(:object)]
      args.insert(3, nil) if Rails::VERSION::STRING < '2.2'
      ActionView::Helpers::InstanceTag.new(*args).to_datetime_text_field_tag(options)
    end

  end
end
