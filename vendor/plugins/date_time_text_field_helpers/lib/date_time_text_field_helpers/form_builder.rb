module DateTimeTextFieldHelpers
  module FormBuilder
  
    def date_text_field(method, options = {})
      @template.date_text_field(@object_name, method, options.merge(:object => @object))
    end

    def time_text_field(method, options = {})
      @template.time_text_field(@object_name, method, options.merge(:object => @object))
    end

    def datetime_text_field(method, options = {})
      @template.datetime_text_field(@object_name, method, options.merge(:object => @object))
    end
  
  end
end
