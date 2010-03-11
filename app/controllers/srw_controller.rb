# To change this template, choose Tools | Templates
# and open the template in the editor.

class SrwController < ApplicationController
  def index
    #Srw model 自体を省略したほうがよいかもしれない。
    @srw = Srw.new(params[:Envelope])
    query = @srw.cql.to_sunspot
    sort = @srw.sort_by
    start = @srw.start
    maximum = @srw.maximum

    role = current_user.try(:highest_role) || Role.find(1)

    search = Sunspot.new_search(Manifestation)
    search = make_internal_query(search)

    search.build do
      fulltext query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than role.id
    end
    search.query.start_record(start, maximum)

    @manifestations = search.execute!.results

    respond_to do |format|
      format.xml  {render :layout => false}
    end
  rescue QueryError
    render :template => 'srw/error.xml', :layout => false
    return
  end
end
