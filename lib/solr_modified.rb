module ActsAsSolr
  module ParserMethods
    def reorder(things, ids)
      ordered_things = []
      ids.each do |id|
        record = things.find {|thing| record_id(thing).to_s == id.to_s}
        # 削除時に auto_commit が働かないため
        raise "Out of sync! The id #{id} is in the Solr index but missing in the database!" unless record rescue nil
        ordered_things << record
      end
      ordered_things
    end
  end

  module ClassMethods
    def numdocs
      count_by_solr('[* TO *]')
    end
  end

  module InstanceMethods
    def solr_destroy
      logger.debug "solr_destroy: #{self.class.name} : #{record_id(self)}"
       solr_delete solr_id
       solr_commit # if configuration[:auto_commit]
       true
    end
  end
end
