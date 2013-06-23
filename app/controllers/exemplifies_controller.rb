class ExemplifiesController < ApplicationController
  # GET /exemplifies
  # GET /exemplifies.json
  def index
    @exemplifies = Exemplify.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exemplifies }
    end
  end

  # GET /exemplifies/1
  # GET /exemplifies/1.json
  def show
    @exemplify = Exemplify.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @exemplify }
    end
  end

  # GET /exemplifies/new
  # GET /exemplifies/new.json
  def new
    @exemplify = Exemplify.new
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @exemplify.expression = @expression
    @exemplify.manifestation = @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exemplify }
    end
  end

  # GET /exemplifies/1/edit
  def edit
    @exemplify = Exemplify.find(params[:id])
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @exemplify.expression = @expression if @expression
    @exemplify.manifestation = @manifestation if @manifestation
  end

  # POST /exemplifies
  # POST /exemplifies.json
  def create
    @exemplify = Exemplify.new(params[:exemplify])

    respond_to do |format|
      if @exemplify.save
        format.html { redirect_to @exemplify, notice: 'Exemplify was successfully created.' }
        format.json { render json: @exemplify, status: :created, location: @exemplify }
      else
        format.html { render action: "new" }
        format.json { render json: @exemplify.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /exemplifies/1
  # PUT /exemplifies/1.json
  def update
    @exemplify = Exemplify.find(params[:id])

    respond_to do |format|
      if @exemplify.update_attributes(params[:exemplify])
        format.html { redirect_to @exemplify, notice: 'Exemplify was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @exemplify.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exemplifies/1
  # DELETE /exemplifies/1.json
  def destroy
    @exemplify = Exemplify.find(params[:id])
    @exemplify.destroy

    respond_to do |format|
      format.html { redirect_to exemplifies_url }
      format.json { head :no_content }
    end
  end
end
