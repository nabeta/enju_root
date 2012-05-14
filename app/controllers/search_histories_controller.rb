class SearchHistoriesController < ApplicationController
  before_filter :access_denied, :except => [:index, :show, :destroy]
  # index, show以外は外部からは呼び出されないはず
  load_and_authorize_resource

  # GET /search_histories
  # GET /search_histories.json
  def index
    if params[:mode] == 'not_found'
      if current_user.has_role?('Administrator')
        @search_histories = SearchHistory.not_found.paginate(:page => params[:page], :order => ['created_at DESC'])
      else
        @search_histories = current_user.search_histories.not_found.paginate(:page => params[:page], :order => ['created_at DESC'])
      end
    else
      if current_user.has_role?('Administrator')
        @search_histories = SearchHistory.paginate(:page => params[:page], :order => ['created_at DESC'])
      else
        @search_histories = current_user.search_histories.paginate(:page => params[:page], :order => ['created_at DESC'])
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @search_histories }
    end
  end

  # GET /search_histories/1
  # GET /search_histories/1.json
  def show
    @search_history = SearchHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @search_history }
    end
  end

  # GET /search_histories/new
  def new
  #  @search_history = SearchHistory.new
  end

  # GET /search_histories/1/edit
  def edit
  #  @search_history = @user.search_histories.find(params[:id])
  end

  # POST /search_histories
  # POST /search_histories.json
  def create
  #  if @user
  #    @search_history = @user.search_histories.new(params[:search_history])
  #  else
  #    @search_history = SearchHistory.new(params[:search_history])
  #  end
  #
  #  respond_to do |format|
  #    if @search_history.save
  #      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.search_history'))
  #      format.html { redirect_to search_history_url(@search_history) }
  #      format.json { head :created, :location => search_history_url(@search_history) }
  #    else
  #      format.html { render :action => "new" }
  #      format.json { render :json => @search_history.errors }
  #    end
  #  end
  end

  # PUT /search_histories/1
  # PUT /search_histories/1.json
  def update
  #  @search_history = @user.search_histories.find(params[:id])
  #
  #  respond_to do |format|
  #    if @search_history.update_attributes(params[:search_history])
  #      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.search_history'))
  #      format.html { redirect_to user_search_history_url(@user, @search_history) }
  #      format.json { head :no_content }
  #    else
  #      format.html { render :action => "edit" }
  #      format.json { render :json => @search_history.errors }
  #    end
  #  end
  end

  # DELETE /search_histories/1
  # DELETE /search_histories/1.json
  def destroy
    @search_history = SearchHistory.find(params[:id])
    @search_history.destroy

    respond_to do |format|
      #format.html { redirect_to user_search_histories_url(@user.username) }
      format.html { redirect_to search_histories_url }
      format.json { head :no_content }
    end
  end
end
