# http://gist.github.com/72487
module Cash
  module Query
    class Abstract
      delegate :with_exclusive_scope, :get, :table_name, :indices, :find_from_ids_without_cache, :cache_key, :to => :@active_record

      def self.perform(*args)
        new(*args).perform
      end

      def initialize(active_record, options1, options2)
        @active_record, @options1, @options2 = active_record, options1, options2 || {}
      end

      def perform(find_options = {}, get_options = {})
        #if cache_config = cacheable?(@options1, @options2, find_options)
        if @active_record != Tag and cache_config = cacheable?(@options1, @options2, find_options)
          cache_keys, index = cache_keys(cache_config[0]), cache_config[1]

          misses, missed_keys, objects = hit_or_miss(cache_keys, index, get_options)
          format_results(cache_keys, choose_deserialized_objects_if_possible(missed_keys, cache_keys, misses, objects))
        else
          uncacheable
        end
      end

    end
  end
end
