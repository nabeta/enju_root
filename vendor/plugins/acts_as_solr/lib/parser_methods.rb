module ActsAsSolr #:nodoc:
  
  module ParserMethods
    
    protected    
    
    # Method used by mostly all the ClassMethods when doing a search
    def parse_query(query=nil, options={}, models=nil)
      options = options.symbolize_keys
      valid_options = [:offset, :limit, :facets, :models, :results_format, :order, :scores, :operator, :include]
      query_options = {}
      return if query.nil?
      raise "Invalid parameters: #{(options.keys - valid_options).map(&:inspect).join(',')}" unless (options.keys - valid_options).empty?

      begin
        Deprecation.validate_query(options)
        query_options[:start] = options[:offset]
        query_options[:rows] = options[:limit]
        query_options[:operator] = options[:operator]
        
        # first steps on the facet parameter processing
        if options[:facets]
          query_options[:facets] = {}
          query_options[:facets][:limit] = -1  # TODO: make this configurable
          query_options[:facets][:sort] = :count if options[:facets][:sort]
          query_options[:facets][:mincount] = 0
          query_options[:facets][:mincount] = 1 if options[:facets][:zeros] == false
          query_options[:facets][:fields] = options[:facets][:fields].collect{|k| "#{k}_facet"} if options[:facets][:fields]
          query_options[:filter_queries] = replace_types(options[:facets][:browse].collect{|k| "#{k.sub!(/ *: */,"_facet:")}"}) if options[:facets][:browse]
          query_options[:facets][:queries] = replace_types(options[:facets][:query].collect{|k| "#{k.sub!(/ *: */,"_t:")}"}) if options[:facets][:query]
        end
        
        if models.nil?
          # TODO: use a filter query for type, allowing Solr to cache it individually
          models = "#{solr_type_condition}"
          field_list = solr_configuration[:primary_key_field]
        else
          field_list = "id"
        end
        
        query_options[:field_list] = [field_list, 'score']
        
        unless query.nil? || query.empty? || query == '*'
          query = "(#{map_query_to_fields(query)}) AND #{models}"
        else
          query = "#{models}"
        end
        query_options[:query] = query

        logger.debug "SOLR query: #{query.inspect}"

        unless options[:order].blank?
          order = map_order_to_fields(options[:order])
          query_options[:query] << ';' << order
        end
               
        ActsAsSolr::Post.execute(Solr::Request::Standard.new(query_options))
      rescue
        raise "There was a problem executing your search: #{$!}"
      end            
    end
    
    # map index fields to the appropriate lucene_fields
    # "title:(a fish in my head)" => "title_t:(a fish in my head)"
    # it should avoid mapping to _sort fields
    def map_query_to_fields(query)
      #{query.gsub(/ *: */,"_t:")}
      query.gsub(/(\w+)\s*:\s*/) do |match| # sets $1 in the block
        field_name = $1
        field_name = field_name_to_lucene_field(field_name)
        "#{field_name}:"
      end
    end
    
    def map_order_to_fields(string)
      string.split(",").map do |clause|
        field_name, direction = clause.strip.split(/\s+/)
        field_name = field_name_to_lucene_field(field_name, :sort) unless field_name == "score"
        direction ||= "asc"
        
        "#{field_name} #{direction.downcase}"
      end.join(",")
    end
      
    def solr_type_condition
      subclasses.inject("(#{solr_configuration[:type_field]}:#{self.name}") do |condition, subclass|
        condition << " OR #{solr_configuration[:type_field]}:#{subclass.name}"
      end << ')'
    end
   
    # Parses the data returned from Solr
    def parse_results(solr_data, options = {})
      find_options = options.slice(:include)
      results = {
        :docs => [],
        :total => 0
      }
      configuration = {
        :format => :objects
      }
      results.update(:facets => {'facet_fields' => []}) if options[:facets]
      return SearchResults.new(results) if solr_data.total == 0
      
      configuration.update(options) if options.is_a?(Hash)

      ids = solr_data.docs.collect {|doc| doc["#{solr_configuration[:primary_key_field]}"]}.flatten
      conditions = [ "#{self.table_name}.#{primary_key} in (?)", ids ]
      result = configuration[:format] == :objects ? reorder(self.find(:all, find_options.merge(:conditions => conditions)), ids) : ids
      add_scores(result, solr_data) if configuration[:format] == :objects && options[:scores]
      
      # added due to change for solr 1.3 ruby return struct for facet_fields is an array not hash
      if options[:facets] && !solr_data.data['facet_counts']['facet_fields'].empty?
        facet_fields = solr_data.data['facet_counts']['facet_fields']
        solr_data.data['facet_counts']['facet_fields'] = {}
        facet_fields.each do |name, values|
          solr_data.data['facet_counts']['facet_fields'][name] = {}
          values.length.times do | a |
            if a.odd?
              solr_data.data['facet_counts']['facet_fields'][name][values[a-1]] = values[a]
            else
              solr_data.data['facet_counts']['facet_fields'][name][values[a]]
            end
          end    
        end
      end
      
      results.update(:facets => solr_data.data['facet_counts']) if options[:facets]
      results.update({:docs => result, :total => solr_data.total, :max_score => solr_data.max_score})
      SearchResults.new(results)
    end
    
    # Reorders the instances keeping the order returned from Solr
    def reorder(things, ids)
      ordered_things = []
      ids.each do |id|
        record = things.find {|thing| record_id(thing).to_s == id.to_s} 
        if record
          ordered_things << record
        else
          logger.error("SOLR index Out of sync! The id #{id} is in the Solr index but missing in the database!")
          # Should this silently remove missing records from the index?
        end
      end
      ordered_things
    end

    # Replaces the field types based on the types (if any) specified
    # on the acts_as_solr call
    def replace_types(strings, include_colon=true)
      suffix = include_colon ? ":" : ""
      if configuration[:solr_fields]
        configuration[:solr_fields].each do |name, options|
          field = "#{name.to_s}_#{get_solr_field_type(options[:type])}#{suffix}"
          strings.each_with_index {|s,i| strings[i] = s.gsub(/#{name.to_s}_t#{suffix}/,field) }
        end
      end
      strings
    end
    
    # looks through the configured :solr_fields, and chooses the most appropriate
    # pass it :sort if you would prefer a :sort_field
    # or pass it :text if that's your prefered type
    def field_name_to_solr_field(field_name, favoured_types=nil)
      favoured_types = Array(favoured_types)
      
      solr_fields = configuration[:solr_fields].select do |field, options|
        field.to_s == field_name.to_s
      end
      prefered, secondary = solr_fields.partition do |field, options|
        favoured_types.include?(options[:type])
      end
      prefered.first || secondary.first # will return nil if no matches
    end
    
    # takes a normalized field... ie. [:field, {:type => :text}]
    # gets us the lucene field name "field_t"
    def solr_field_to_lucene_field(normalized_field)
      field_name, options = normalized_field
      field_type = options[:type]
      "#{field_name}_#{get_solr_field_type(field_type)}"
    end
    
    # "title" => "title_t", or "title_sort"
    # "score" => "score" -- SPECIAL CASE
    def field_name_to_lucene_field(field_name, favoured_types=[:string, :text])
      if normalized_field = field_name_to_solr_field(field_name, favoured_types)
        solr_field_to_lucene_field(normalized_field)
      else
        field_name.to_s
      end
    end
    
    # Adds the score to each one of the instances found
    def add_scores(results, solr_data)
      with_score = []
      solr_data.docs.each do |doc|
        with_score.push([doc["score"], 
          results.find {|record| record_id(record).to_s == doc["#{solr_configuration[:primary_key_field]}"].to_s }])
      end
      with_score.each do |score,object| 
        class <<object; attr_accessor :solr_score; end
        object.solr_score = score
      end
    end
  end

end
