module PortaController
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def search_porta_crd(query, options = {})
      results = {}
      results[:count] = 0
      crd_startrecord = (options[:page].to_i - 1) * Question.crd_per_page + 1
      if crd_startrecord < 1
        crd_startrecord = 1
      end
      if options[:page]
        crd_page = options[:page].to_i
      else
        crd_page = 1
      end
      refkyo_resource = Question.search_porta(query, {:dpid => 'refkyo', :item => 'any', :raw => false, :startrecord => crd_startrecord.to_i, :per_page => Question.crd_per_page})
      resources = refkyo_resource.items
      refkyo_count = refkyo_resource.channel.totalResults.to_i
      if refkyo_count > 1000
        crd_total_count = 1000
      else
        crd_total_count = refkyo_count
      end
      crd_results = WillPaginate::Collection.create(crd_page, Question.crd_per_page, crd_total_count) do |pager| pager.replace(resources) end
      results = {:resources => crd_results, :count => refkyo_count}
    end

  end
end
