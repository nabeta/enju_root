class ProducesController < ApplicationController
  # GET /produces
  # GET /produces.json
  def index
    @produces = Produce.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @produces }
    end
  end

  # GET /produces/1
  # GET /produces/1.json
  def show
    @produce = Produce.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @produce }
    end
  end

  # GET /produces/new
  # GET /produces/new.json
  def new
    @produce = Produce.new
    @person = Person.find(params[:person_id]) if params[:person_id]
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @produce.person = @person
    @produce.manifestation = @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @produce }
    end
  end

  # GET /produces/1/edit
  def edit
    @produce = Produce.find(params[:id])
  end

  # POST /produces
  # POST /produces.json
  def create
    @produce = Produce.new(params[:produce])

    respond_to do |format|
      if @produce.save
        format.html { redirect_to @produce, notice: 'Produce was successfully created.' }
        format.json { render json: @produce, status: :created, location: @produce }
      else
        format.html { render action: "new" }
        format.json { render json: @produce.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /produces/1
  # PUT /produces/1.json
  def update
    @produce = Produce.find(params[:id])

    respond_to do |format|
      if @produce.update_attributes(params[:produce])
        format.html { redirect_to @produce, notice: 'Produce was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @produce.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /produces/1
  # DELETE /produces/1.json
  def destroy
    @produce = Produce.find(params[:id])
    @produce.destroy

    respond_to do |format|
      format.html { redirect_to produces_url }
      format.json { head :no_content }
    end
  end
end
