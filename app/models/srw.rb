require 'forwardable'
#require 'rubygems'
require 'sru'

class Srw
  extend Forwardable

  def initialize(body)
    @sru = Sru.new(body[:Body][:searchRetrieveRequest])
  end
  
  def_delegators :@sru, :search, :sort_by, :cql, :version,:packing, :schema, :start, :maximum
  def_delegators :@sru, :number_of_records, :next_record_position, :extra_response_data
end


#if $PROGRAM_NAME == __FILE__
#  require 'srw_test'
#end
