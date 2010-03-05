# To change this template, choose Tools | Templates
# and open the template in the editor.

class SrwController < ApplicationController
  def index
    @srw = Srw.new(params[:body])
    query = @srw.cql.to_sunspot
    sort = @srw.sort_by
    role = current_user.try(:highest_role) || Role.find(1)

    search = Sunspot.new_search(Manifestation)
    search = make_internal_query(search)

    search.build do
      fulltext query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than role.id
    end

    #    search.query.paginate(page.to_i, Manifestation.per_page)
    @manifestations = search.execute!.results

    respond_to do |format|
      format.xml  {render :layout => false}
    end
  rescue QueryError
    render :template => 'srw/error.xml', :layout => false
    return
  end
end