require 'porta_cql'

class QueryArgumentError < QueryError; end

class Sru
  def initialize(params)
    raise QueryArgumentError, 'sru :query is required item.' unless params.has_key?(:query)

    @cql = Cql.new(params[:query])
    @version = params.has_key?(:version) ? params[:version] : '1.2'
    @start = params.has_key?(:startRecord) ? params[:startRecord].to_i : 1
    @maximum = params.has_key?(:maximumRecords) ? params[:maximumRecords].to_i : 200
    @packing = params.has_key?(:recordPacking) ? params[:recordPacking] : 'string'
    @schema = params.has_key?(:recordSchema) ? params[:recordSchema] : 'dc'
    @sort_key = params[:sortKeys]

    @manifestations = []
    @extra_response_data = {}
  end

  attr_reader :version, :cql, :start, :maximum, :packing, :schema, :path, :ascending
  attr_reader :manifestations, :extra_response_data, :number_of_records, :next_record_position
  
  def sort_by
    sort = {:sort_by => 'created_at', :order => 'desc'}
    unless '1.1' == @version
      @path, @ascending = @cql.sort_by.split('/')
    else
      @path, @ascending = @sort_key.split(',') if @sort_key
    end
    sort[:sort_by] = @path if @path
    #TODO ソート基準が入手しやすさの場合の処理
    sort[:order] = 'asc' if /(\A1|ascending)\Z/ =~ @ascending
    sort
  end

  def search
    sunspot_query = @cql.to_sunspot
    search = Sunspot.new_search(Manifestation)
    search.build{ fulltext sunspot_query}
    @manifestations = search.execute!.results
    @extra_response_data = get_extra_response_data
    @number_of_records, @next_record_position = get_number_of_records
  end
  
  def get_extra_response_data
    #TODO: NDL で必要な項目が決定し、更に enju にそのフィールドが設けられた後で正式な実装を行なう。
    if @search.respond_to?(:erd)
      @schema == 'dc' ? @search.erd : {}
    end
  end

  def get_number_of_records
    #TODO: sunspot での取得方法が分かり次第、正式な実装を行なう。
    @schema == 'dc' ? [1405, 1406] : [40,11]
  end
end

if $PROGRAM_NAME == __FILE__
  require 'sru_test'
end
