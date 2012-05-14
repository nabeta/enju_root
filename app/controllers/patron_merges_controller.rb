class PatronMergesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_patron, :get_patron_merge_list

  # GET /patron_merges
  # GET /patron_merges.json
  def index
    if @patron
      @patron_merges = @patron.patron_merges.paginate(:page => params[:page], :order => ['patron_merges.id'])
    elsif @patron_merge_list
      @patron_merges = @patron_merge_list.patron_merges.paginate(:page => params[:page], :include => 'patron', :order => ['patron_merges.id'])
    else
      @patron_merges = PatronMerge.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patron_merges }
    end
  end

  # GET /patron_merges/1
  # GET /patron_merges/1.json
  def show
    @patron_merge = PatronMerge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @patron_merge }
    end
  end

  # GET /patron_merges/new
  # GET /patron_merges/new.json
  def new
    @patron_merge = PatronMerge.new
    @patron_merge.patron = @patron

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @patron_merge }
    end
  end

  # GET /patron_merges/1/edit
  def edit
    @patron_merge = PatronMerge.find(params[:id])
  end

  # POST /patron_merges
  # POST /patron_merges.json
  def create
    @patron_merge = PatronMerge.new(params[:patron_merge])

    respond_to do |format|
      if @patron_merge.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_merge'))
        format.html { redirect_to(@patron_merge) }
        format.json { render :json => @patron_merge, :status => :created, :location => @patron_merge }
      else
        format.html { render :action => "new" }
        format.json { render :json => @patron_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_merges/1
  # PUT /patron_merges/1.json
  def update
    @patron_merge = PatronMerge.find(params[:id])
    #selected_patron = Patron.find(params[:selected_patron_id])
    #@patron_merge.patrons.each do |patron|
    #  Create.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #  Realize.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #  Produce.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #  Own.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #  PatronOwnsLibrary.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #  Donation.update_all(['patron_id = ?', selected_patron.id], ['patron_id = ?', patron.id])
    #end

    respond_to do |format|
      if @patron_merge.update_attributes(params[:patron_merge])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_merge'))
        format.html { redirect_to(@patron_merge) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @patron_merge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_merges/1
  # DELETE /patron_merges/1.json
  def destroy
    @patron_merge = PatronMerge.find(params[:id])
    @patron_merge.destroy

    respond_to do |format|
      format.html { redirect_to(patron_merges_url) }
      format.json { head :no_content }
    end
  end
end
