class TagsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  require_role 'Librarian', :only => [:edit, :update, :destroy]
  before_filter :get_user_if_nil

  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]

  def index
    session[:params] ={} unless session[:params]
    session[:params][:tag] = params

    @per_page = 10
    if params[:order] == 'name'
      order = 'name'
    elsif params[:order] == 'taggings_count'
      order = 'taggings_count desc'
    else
      order = 'created_at desc'
    end
    if @user
      @tags = @user.tags.paginate(:all, :page => params[:page], :per_page => @per_page, :order => order, :conditions => ['taggings_count > 0'])
    else
      @tags = Tag.paginate(:all, :page => params[:page], :per_page => @per_page, :order => order, :conditions => ['taggings_count > 0'])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find(:first, :conditions => {:name => params[:id]})
    raise ActiveRecord::RecordNotFound if @tag.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def edit
    @tag = Tag.find(:first, :conditions => {:name => params[:id]})
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def update
    @tag = Tag.find(:first, :conditions => {:name => params[:id]})

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.tag'))
        format.html { redirect_to tag_url(@tag.name) }
        format.xml  { head :ok }
      else
        @tag = Tag.find(:first, :conditions => {:name => params[:id]})
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
    @tag = Tag.find(:first, :conditions => {:name => params[:id]})
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
