module ActsAsSolr #:nodoc:
  
  module ActsMethods
    
    # declares a class as solr-searchable
    # 
    # ==== options:
    # fields:: This option can be used to specify only the fields you'd
    #          like to index. If not given, all the attributes from the 
    #          class will be indexed. You can also use this option to 
    #          include methods that should be indexed as fields
    # 
    #           class Movie < ActiveRecord::Base
    #             acts_as_solr :fields => [:name, :description, :current_time]
    #             def current_time
    #               Time.now.to_s
    #             end
    #           end
    #          
    #          Each field passed can also be a hash with the value being a field type
    # 
    #           class Electronic < ActiveRecord::Base
    #             acts_as_solr :fields => [{:price => :range_float}]
    #             def current_time
    #               Time.now
    #             end
    #           end
    # 
    #          The field types accepted are:
    # 
    #          :float:: Index the field value as a float (ie.: 12.87)
    #          :integer:: Index the field value as an integer (ie.: 31)
    #          :boolean:: Index the field value as a boolean (ie.: true/false)
    #          :date:: Index the field value as a date (ie.: Wed Nov 15 23:13:03 PST 2006)
    #          :string:: Index the field value as a text string, not applying the same indexing
    #                    filters as a regular text field
    #          :range_integer:: Index the field value for integer range queries (ie.:[5 TO 20])
    #          :range_float:: Index the field value for float range queries (ie.:[14.56 TO 19.99])
    # 
    #          Setting the field type preserves its original type when indexed
    # 
    # additional_fields:: This option takes fields to be include in the index
    #                     in addition to those derived from the database. You
    #                     can also use this option to include custom fields 
    #                     derived from methods you define. This option will be
    #                     ignored if the :fields option is given. It also accepts
    #                     the same field types as the option above
    # 
    #                      class Movie < ActiveRecord::Base
    #                       acts_as_solr :additional_fields => [:current_time]
    #                       def current_time
    #                         Time.now.to_s
    #                       end
    #                      end
    # 
    # exclude_fields:: This option taks an array of fields that should be ignored from indexing:
    # 
    #                    class User < ActiveRecord::Base
    #                      acts_as_solr :exclude_fields => [:password, :login, :credit_card_number]
    #                    end
    # 
    # include:: This option can be used for association indexing, which 
    #           means you can include any :has_one, :has_many, :belongs_to 
    #           and :has_and_belongs_to_many association to be indexed:
    # 
    #            class Category < ActiveRecord::Base
    #              has_many :books
    #              acts_as_solr :include => [:books]
    #            end
    # 
    # facets:: This option can be used to specify the fields you'd like to
    #          index as facet fields
    # 
    #           class Electronic < ActiveRecord::Base
    #             acts_as_solr :facets => [:category, :manufacturer]  
    #           end
    # 
    # boost:: You can pass a boost (float) value that will be used to boost the document and/or a field:
    # 
    #           class Electronic < ActiveRecord::Base
    #             acts_as_solr :fields => [{:price => {:boost => 5.0}}], :boost => 10.0
    #           end
    # 
    # if:: Only indexes the record if the condition evaluated is true. The argument has to be 
    #      either a symbol, string (to be eval'ed), proc/method, or class implementing a static 
    #      validation method. It behaves the same way as ActiveRecord's :if option.
    # 
    #        class Electronic < ActiveRecord::Base
    #          acts_as_solr :if => proc{|record| record.is_active?}
    #        end
    # 
    # auto_commit:: The commit command will be sent to Solr only if its value is set to true:
    # 
    #                 class Author < ActiveRecord::Base
    #                   acts_as_solr :auto_commit => false
    #                 end
    # 
    # silence_failures:: When true a failure to save a record to solr
    #   will *not* prevent the rest of the callbacks from running
    #   ActiveRecord from being saved.  Default: false
    #
    # auto_save:: When true saving the model will also save a
    #   corresponding record to solr, otherwise that step is skipped.
    #   Default: true

    def acts_as_solr(options={}, solr_options={})
      
      extend ClassMethods
      include InstanceMethods
      include CommonMethods
      include ParserMethods
      
      cattr_accessor :configuration
      cattr_accessor :solr_configuration
      
      self.configuration = { 
        :fields => nil,
        :additional_fields => nil,
        :exclude_fields => [],
        :auto_commit => true,
        :include => nil,
        :facets => nil,
        :boost => nil,
        :if => "true",
        :silence_failures => false,
        :auto_save => true
      }  
      
      self.solr_configuration = {
        :type_field => "type_s",
        :primary_key_field => "pk_i",
        :default_boost => 1.0
      }
      
      configuration.update(options) if options.is_a?(Hash)
      solr_configuration.update(solr_options) if solr_options.is_a?(Hash)
      Deprecation.validate_index(configuration)
      
      configuration[:solr_fields] = []
      
      after_save(:solr_save) if self.configuration[:auto_save]
      after_destroy(:solr_destroy)

      if configuration[:fields].respond_to?(:each)
        process_fields(configuration[:fields])
      else
        process_fields(self.new.attributes.keys.map { |k| k.to_sym })
        process_fields(configuration[:additional_fields])
      end
      
      if configuration[:sort_fields]
        process_fields(configuration[:sort_fields].collect {|field| {field => :sort}})
      end
    end
    
    private
    def get_field_value(field)
      # normalized format: [:field_name, {:type => whatever, :boost => :whatever}]
      options = normalize_field_options(field)
      configuration[:solr_fields] << options
      field_name = options.first
      
      unless instance_methods.include?("#{field_name}_for_solr")
        define_method("#{field_name}_for_solr".to_sym) do
          value = self.send(field_name.to_sym)

          case options.last[:type] 
            # format dates properly; return nil for nil dates 
            when :date: value ? value.utc.strftime("%Y-%m-%dT%H:%M:%SZ") : nil 
            else value
          end
        end
      end
    end
    
    def process_fields(raw_field)
      if raw_field.respond_to?(:each)
        raw_field.each do |field|
          next if configuration[:exclude_fields].include?(field)
          get_field_value(field)
        end                
      end
    end
    
    def type_for_field(field)
      if configuration[:facets] && configuration[:facets].include?(field)
        :facet
      elsif column = columns_hash[field.to_s]
        case column.type
        when :string then :text
        when :datetime then :date
        when :time then :date
        else column.type
        end
      else
        :text
      end
    end
    
    def normalize_field_options(field)
      if field.is_a?(Hash)
        name = field.keys.first
        options = field.values.first
        if options.is_a?(Hash)
          [name, {:type => type_for_field(field)}.merge(options)]
        else
          [name, {:type => options}]
        end
      else
        [field, {:type => type_for_field(field)}]
      end
    end
  end
end
