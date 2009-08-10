class TagsController < ApplicationController
  before_filter :has_permission?
  before_filter :get_user_if_nil

  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  def index
    session[:params] ={} unless session[:params]
    session[:params][:tag] = params

    sort = {:sort_by => 'created_at', :sort => 'desc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'name'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = @query = params[:query].to_s.strip
    page = params[:page] || 1

    if query.present?
      begin
        tag_ids = Tag.search_ids do
          keywords query
          order_by sort[:sort_by], sort[:order]
          paginate :page => page.to_i, :per_page => Tag.per_page
        end
        @tags = Tag.paginate(:conditions => {:id => tag_ids}, :page => page)
      rescue RSolr::RequestError
        @tags = WillPaginate::Collection.create(1,1,0) do end
      end
    else
      @tags = Tag.paginate(:all, :page => page, :order => "#{sort[:sort_by]} #{sort[:order]}")
    end


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find(params[:id])
    raise ActiveRecord::RecordNotFound if @tag.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def edit
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def update
    @tag = Tag.find(params[:id])
  
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.tag'))
        format.html { redirect_to tag_url(@tag.name) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors.to_xml }
      end
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
