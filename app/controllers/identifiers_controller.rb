class IdentifiersController < ApplicationController
  # GET /identifiers
  # GET /identifiers.json
  def index
    @identifiers = Identifier.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @identifiers }
    end
  end

  # GET /identifiers/1
  # GET /identifiers/1.json
  def show
    @identifier = Identifier.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @identifier }
    end
  end

  # GET /identifiers/new
  # GET /identifiers/new.json
  def new
    @identifier = Identifier.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @identifier }
    end
  end

  # GET /identifiers/1/edit
  def edit
    @identifier = Identifier.find(params[:id])
  end

  # POST /identifiers
  # POST /identifiers.json
  def create
    @identifier = Identifier.new(params[:identifier])

    respond_to do |format|
      if @identifier.save
        format.html { redirect_to @identifier, notice: 'Identifier was successfully created.' }
        format.json { render json: @identifier, status: :created, location: @identifier }
      else
        format.html { render action: "new" }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /identifiers/1
  # PUT /identifiers/1.json
  def update
    @identifier = Identifier.find(params[:id])

    respond_to do |format|
      if @identifier.update_attributes(params[:identifier])
        format.html { redirect_to @identifier, notice: 'Identifier was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.json
  def destroy
    @identifier = Identifier.find(params[:id])
    @identifier.destroy

    respond_to do |format|
      format.html { redirect_to identifiers_url }
      format.json { head :no_content }
    end
  end
end
