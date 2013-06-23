class ReifiesController < ApplicationController
  before_filter :prepare_options, :only => [:new, :edit]
  # GET /reifies
  # GET /reifies.json
  def index
    @reifies = Reify.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reifies }
    end
  end

  # GET /reifies/1
  # GET /reifies/1.json
  def show
    @reify = Reify.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reify }
    end
  end

  # GET /reifies/new
  # GET /reifies/new.json
  def new
    @reify = Reify.new
    @work = Work.find(params[:work_id]) if params[:work_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @reify.work = @work
    @reify.expression = @expression
    @manifestation_id = Manifestation.find(params[:manifestation_id]).id if params[:manifestation_id]
    if @manifestation_id and @work
      expression = Expression.create(:original_title => @work.original_title)
      @reify.expression = expression
      @reify.save
      redirect_to new_embody_path(:expression_id => expression.id, :manifestation_id => @manifestation_id)
      return
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reify }
    end
  end

  # GET /reifies/1/edit
  def edit
    @reify = Reify.find(params[:id])
    @work = Work.find(params[:work_id]) if params[:work_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @reify.work = @work if @work
    @reify.expression = @expression if @expression
  end

  # POST /reifies
  # POST /reifies.json
  def create
    @reify = Reify.new(params[:reify])

    respond_to do |format|
      if @reify.save
        format.html { redirect_to @reify, notice: 'Reify was successfully created.' }
        format.json { render json: @reify, status: :created, location: @reify }
      else
        format.html { render action: "new" }
        format.json { render json: @reify.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reifies/1
  # PUT /reifies/1.json
  def update
    @reify = Reify.find(params[:id])

    respond_to do |format|
      if @reify.update_attributes(params[:reify])
        format.html { redirect_to @reify, notice: 'Reify was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reify.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reifies/1
  # DELETE /reifies/1.json
  def destroy
    @reify = Reify.find(params[:id])
    @reify.destroy

    respond_to do |format|
      format.html { redirect_to reifies_url }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @relationship_types = ExpressionRelationshipType.order(:position)
  end
end
