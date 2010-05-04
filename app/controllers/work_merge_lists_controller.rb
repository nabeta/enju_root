class WorkMergeListsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /work_merge_lists
  # GET /work_merge_lists.xml
  def index
    @work_merge_lists = WorkMergeList.paginate(:all, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @work_merge_lists }
    end
  end

  # GET /work_merge_lists/1
  # GET /work_merge_lists/1.xml
  def show
    @work_merge_list = WorkMergeList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @work_merge_list }
    end
  end

  # GET /work_merge_lists/new
  # GET /work_merge_lists/new.xml
  def new
    @work_merge_list = WorkMergeList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @work_merge_list }
    end
  end

  # GET /work_merge_lists/1/edit
  def edit
    @work_merge_list = WorkMergeList.find(params[:id])
  end

  # POST /work_merge_lists
  # POST /work_merge_lists.xml
  def create
    @work_merge_list = WorkMergeList.new(params[:work_merge_list])

    respond_to do |format|
      if @work_merge_list.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.work_merge_list'))
        format.html { redirect_to(@work_merge_list) }
        format.xml  { render :xml => @work_merge_list, :status => :created, :location => @work_merge_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /work_merge_lists/1
  # PUT /work_merge_lists/1.xml
  def update
    @work_merge_list = WorkMergeList.find(params[:id])

    respond_to do |format|
      if @work_merge_list.update_attributes(params[:work_merge_list])
        if params[:mode] == 'merge'
          if selected_work = Work.find(params[:selected_work_id]) rescue nil
            @work_merge_list.merge_works(selected_work)
            flash[:notice] = ('Works are merged successfully.')
          else
            flash[:notice] = ('Specify work id.')
            redirect_to work_merge_list_url(@work_merge_list)
            return
          end
        else
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.work_merge_list'))
        end
        format.html { redirect_to(@work_merge_list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /work_merge_lists/1
  # DELETE /work_merge_lists/1.xml
  def destroy
    @work_merge_list = WorkMergeList.find(params[:id])
    @work_merge_list.destroy

    respond_to do |format|
      format.html { redirect_to(work_merge_lists_url) }
      format.xml  { head :ok }
    end
  end
end
