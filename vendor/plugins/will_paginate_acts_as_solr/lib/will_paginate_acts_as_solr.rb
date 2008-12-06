require 'will_paginate'
require 'acts_as_solr'
module ActsAsSolr #:nodoc:
  module ClassMethods
    # this is a copy of WillPaginate#paginate specialized for "find_by_solr"
    def paginate_by_solr(*args, &block)
      options = args.extract_options!
      options.symbolize_keys!
      page, per_page, total_entries = wp_parse_options(options)

      WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
        count_options = options.except(:page, :per_page, :total_entries, :finder)
        find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page)
        
        args << find_options.symbolize_keys # else we may break something
        found = find_by_solr(*args, &block)
        pager.total_entries = found.total_hits
        found = found.docs
        pager.replace found
      end
    end
  end
end

module WillPaginateActsAsSolr
  module ViewHelpers
     # a copy of :page_entries_info
     # retrofitting JGP's header style
     def will_paginate_header(collection, options = {})
       entry_name = options[:entry_name] ||
         (collection.empty?? 'result' : collection.first.class.name.underscore.sub('_', ' '))

         %{Showing <b>%d</b> to <b>%d</b> of <b>%d</b> #{entry_name.pluralize}} % [
           collection.entry_range.first,
           collection.entry_range.last,
           collection.total_entries
         ]
     end
   end
   ActionView::Base.class_eval { include ViewHelpers }
end