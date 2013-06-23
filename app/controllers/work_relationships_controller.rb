class WorkRelationshipsController < ApplicationController
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /work_relationships
  # GET /work_relationships.json
  def index
    @work_relationships = WorkRelationship.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_relationships }
    end
  end

  # GET /work_relationships/1
  # GET /work_relationships/1.json
  def show
    @work_relationship = WorkRelationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_relationship }
    end
  end

  # GET /work_relationships/new
  # GET /work_relationships/new.json
  def new
    @work_relationship = WorkRelationship.new
    @work_relationship.parent = Work.find(params[:parent_id])
    @work_relationship.child = Work.find(params[:child_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_relationship }
    end
  end

  # GET /work_relationships/1/edit
  def edit
    @work_relationship = WorkRelationship.find(params[:id])
  end

  # POST /work_relationships
  # POST /work_relationships.json
  def create
    @work_relationship = WorkRelationship.new(params[:work_relationship])

    respond_to do |format|
      if @work_relationship.save
        format.html { redirect_to @work_relationship, notice: 'Work relationship was successfully created.' }
        format.json { render json: @work_relationship, status: :created, location: @work_relationship }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @work_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /work_relationships/1
  # PUT /work_relationships/1.json
  def update
    @work_relationship = WorkRelationship.find(params[:id])

    respond_to do |format|
      if @work_relationship.update_attributes(params[:work_relationship])
        format.html { redirect_to @work_relationship, notice: 'Work relationship was successfully updated.' }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @work_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_relationships/1
  # DELETE /work_relationships/1.json
  def destroy
    @work_relationship = WorkRelationship.find(params[:id])
    @work_relationship.destroy

    respond_to do |format|
      format.html { redirect_to work_relationships_url }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @relationship_types = WorkRelationshipType.all
  end
end
