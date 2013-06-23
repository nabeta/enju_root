class CarrierTypesController < ApplicationController
  # GET /carrier_types
  # GET /carrier_types.json
  def index
    @carrier_types = CarrierType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @carrier_types }
    end
  end

  # GET /carrier_types/1
  # GET /carrier_types/1.json
  def show
    @carrier_type = CarrierType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @carrier_type }
    end
  end

  # GET /carrier_types/new
  # GET /carrier_types/new.json
  def new
    @carrier_type = CarrierType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @carrier_type }
    end
  end

  # GET /carrier_types/1/edit
  def edit
    @carrier_type = CarrierType.find(params[:id])
  end

  # POST /carrier_types
  # POST /carrier_types.json
  def create
    @carrier_type = CarrierType.new(params[:carrier_type])

    respond_to do |format|
      if @carrier_type.save
        format.html { redirect_to @carrier_type, notice: 'Carrier type was successfully created.' }
        format.json { render json: @carrier_type, status: :created, location: @carrier_type }
      else
        format.html { render action: "new" }
        format.json { render json: @carrier_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /carrier_types/1
  # PUT /carrier_types/1.json
  def update
    @carrier_type = CarrierType.find(params[:id])

    respond_to do |format|
      if @carrier_type.update_attributes(params[:carrier_type])
        format.html { redirect_to @carrier_type, notice: 'Carrier type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @carrier_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carrier_types/1
  # DELETE /carrier_types/1.json
  def destroy
    @carrier_type = CarrierType.find(params[:id])
    @carrier_type.destroy

    respond_to do |format|
      format.html { redirect_to carrier_types_url }
      format.json { head :no_content }
    end
  end
end
