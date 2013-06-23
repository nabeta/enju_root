class WorksController < ApplicationController
  # GET /works
  # GET /works.json
  def index
    @parent_work = Work.find(params[:parent_id]) if params[:parent_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    if @expression
      @reify = Reify.where(:expression_id => @expression.id, :work_id => @expression.work.id).first
    end
    @manifestation_id = Manifestation.find(params[:manifestation_id]).id if params[:manifestation_id]
    if params[:manifestation_url].present?
      if Manifestation.where(:url => params[:manifestation_url]).first
        flash[:notice] = 'This manifestation URL is already registered.'
      end
    end
    @person = person = Person.find(params[:person_id]) if params[:person_id]
    @query = params[:query]
    @works = Work.search do
      adjust_solr_params do |params|
        params[:defType] = 'edismax'
      end
      if params[:mode] != 'add'
        with(:creator_ids).equal_to person.id if person
      end
      fulltext params[:query]
      paginate :page => params[:page], :per_page => Work.default_per_page
    end.results

    respond_to do |format|
      format.html # index.html.erb
      format.json #{ render json: @works }
    end
  end

  # GET /works/1
  # GET /works/1.json
  def show
    @work = Work.find(params[:id])
    @manifestation_id = Manifestation.find(params[:manifestation_id]).id if params[:manifestation_id]

    respond_to do |format|
      format.html # show.html.erb
      format.json #{ render json: @work }
      format.xml
      format.svg {
        send_file "#{Rails.root.to_s}/public/work_#{@work.id}.svg", :disposition => "inline", :type => "image/svg+xml"
      }
    end
  end

  # GET /works/new
  # GET /works/new.json
  def new
    @work = Work.new
    @work.work_url = params[:work_url]
    @work.manifestation_url = params[:manifestation_url]
    if @work.manifestation_url.present?
      if Manifestation.where(:url => @work.manifestation_url).first
        flash[:notice] = 'This manifestation url is registered'
      end
    end
    @manifestation_id = Manifestation.find(params[:manifestation_id]).id if params[:manifestation_id]
    @work.manifestation_id = @manifestation_id
    if params[:parent_id]
      @parent_work = Work.find(params[:parent_id])
      @work.parent_id = @parent_work.id
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work }
    end
  end

  # GET /works/1/edit
  def edit
    @work = Work.find(params[:id])
  end

  # POST /works
  # POST /works.json
  def create
    if params[:mode] == 'fetch'
      Work.fetch(params[:work_url])
    end
    @work = Work.new(params[:work])
    manifestation = Manifestation.find(@work.manifestation_id) rescue nil
    parent = Work.find(@work.parent_id) if @work.parent_id.present?

    respond_to do |format|
      if @work.save
        if parent
          parent.children << @work
        end
        if @work.work_url
          @work.fetch
        elsif @work.manifestation_url
          format.html { redirect_to new_expression_url(:work_id => @work, :manifestation_url => @work.manifestation_url), :notice => 'Work was successfully created.' }
        else
          format.html { redirect_to new_expression_url(:work_id => @work, :manifestation_url => @work.manifestation_url), :notice => 'Work was successfully created.' }
        end
        format.json { render json: @work, status: :created, location: @work }
      else
        format.html { render action: "new" }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /works/1
  # PUT /works/1.json
  def update
    @work = Work.find(params[:id])

    respond_to do |format|
      if @work.update_attributes(params[:work])
        format.html { redirect_to @work, notice: 'Work was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @work.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /works/1
  # DELETE /works/1.json
  def destroy
    @work = Work.find(params[:id])
    @work.destroy

    respond_to do |format|
      format.html { redirect_to works_url }
      format.json { head :no_content }
    end
  end
end
