class PatronsController < ApplicationController
  # GET /patrons
  # GET /patrons.json
  def index
    @patrons = Patron.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @patrons }
    end
  end

  # GET /patrons/1
  # GET /patrons/1.json
  def show
    @patron = Patron.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @patron }
    end
  end

  # GET /patrons/new
  # GET /patrons/new.json
  def new
    @patron = Patron.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @patron }
    end
  end

  # GET /patrons/1/edit
  def edit
    @patron = Patron.find(params[:id])
  end

  # POST /patrons
  # POST /patrons.json
  def create
    @patron = Patron.new(params[:patron])

    respond_to do |format|
      if @patron.save
        format.html { redirect_to @patron, notice: 'Patron was successfully created.' }
        format.json { render json: @patron, status: :created, location: @patron }
      else
        format.html { render action: "new" }
        format.json { render json: @patron.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /patrons/1
  # PUT /patrons/1.json
  def update
    @patron = Patron.find(params[:id])

    respond_to do |format|
      if @patron.update_attributes(params[:patron])
        format.html { redirect_to @patron, notice: 'Patron was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @patron.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patrons/1
  # DELETE /patrons/1.json
  def destroy
    @patron = Patron.find(params[:id])
    @patron.destroy

    respond_to do |format|
      format.html { redirect_to patrons_url }
      format.json { head :no_content }
    end
  end
end
