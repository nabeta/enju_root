class WorkRelationshipTypesController < ApplicationController
  # GET /work_relationship_types
  # GET /work_relationship_types.json
  def index
    @work_relationship_types = WorkRelationshipType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_relationship_types }
    end
  end

  # GET /work_relationship_types/1
  # GET /work_relationship_types/1.json
  def show
    @work_relationship_type = WorkRelationshipType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_relationship_type }
    end
  end

  # GET /work_relationship_types/new
  # GET /work_relationship_types/new.json
  def new
    @work_relationship_type = WorkRelationshipType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_relationship_type }
    end
  end

  # GET /work_relationship_types/1/edit
  def edit
    @work_relationship_type = WorkRelationshipType.find(params[:id])
  end

  # POST /work_relationship_types
  # POST /work_relationship_types.json
  def create
    @work_relationship_type = WorkRelationshipType.new(params[:work_relationship_type])

    respond_to do |format|
      if @work_relationship_type.save
        format.html { redirect_to @work_relationship_type, notice: 'Work relationship type was successfully created.' }
        format.json { render json: @work_relationship_type, status: :created, location: @work_relationship_type }
      else
        format.html { render action: "new" }
        format.json { render json: @work_relationship_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /work_relationship_types/1
  # PUT /work_relationship_types/1.json
  def update
    @work_relationship_type = WorkRelationshipType.find(params[:id])

    respond_to do |format|
      if @work_relationship_type.update_attributes(params[:work_relationship_type])
        format.html { redirect_to @work_relationship_type, notice: 'Work relationship type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @work_relationship_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_relationship_types/1
  # DELETE /work_relationship_types/1.json
  def destroy
    @work_relationship_type = WorkRelationshipType.find(params[:id])
    @work_relationship_type.destroy

    respond_to do |format|
      format.html { redirect_to work_relationship_types_url }
      format.json { head :no_content }
    end
  end
end
