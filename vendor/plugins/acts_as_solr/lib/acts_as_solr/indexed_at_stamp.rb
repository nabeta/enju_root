module ActsAsSolr::IndexedAtStamp
  def self.included(base)
    base.module_eval do
      alias_method_chain :solr_save, :indexed_at_stamp
    end
  end
  
  def solr_save_with_indexed_at_stamp(force = false)
    returning(solr_save_without_indexed_at_stamp(force)) do
      stamp_last_indexed_at_if_column_exists
    end
  end
  
  def stamp_last_indexed_at_if_column_exists
    if column = column_for_attribute('indexed_at')
      connection.update(
        "UPDATE #{self.class.quoted_table_name} " +
        "SET #{quoted_comma_pair_list(connection, 'indexed_at' => quote_value(Time.now, column))} " +
        "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)}",
        "#{self.class.name} Stamp last indexed at"
      )
    end
  end
  
  module ClassMethods
    def without_index
      self.all :conditions => {:indexed_at => nil}
    end
    
    def with_outdated_index
      self.all :conditions => ["(indexed_at IS NULL OR (indexed_at < updated_at))"]
    end
  end
end

ActsAsSolr::InstanceMethods.module_eval do
  include ActsAsSolr::IndexedAtStamp
end

ActsAsSolr::ClassMethods.module_eval do
  include ActsAsSolr::IndexedAtStamp::ClassMethods
end
