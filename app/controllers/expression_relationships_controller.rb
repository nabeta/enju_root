class ExpressionRelationshipsController < ApplicationController
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /expression_relationships
  # GET /expression_relationships.json
  def index
    @expression_relationships = ExpressionRelationship.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expression_relationships }
    end
  end

  # GET /expression_relationships/1
  # GET /expression_relationships/1.json
  def show
    @expression_relationship = ExpressionRelationship.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expression_relationship }
    end
  end

  # GET /expression_relationships/new
  # GET /expression_relationships/new.json
  def new
    @expression_relationship = ExpressionRelationship.new
    @expression_relationship.parent = Expression.find(params[:parent_id])
    @expression_relationship.child = Expression.find(params[:child_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @expression_relationship }
    end
  end

  # GET /expression_relationships/1/edit
  def edit
    @expression_relationship = ExpressionRelationship.find(params[:id])
  end

  # POST /expression_relationships
  # POST /expression_relationships.json
  def create
    @expression_relationship = ExpressionRelationship.new(params[:expression_relationship])

    respond_to do |format|
      if @expression_relationship.save
        format.html { redirect_to @expression_relationship, notice: 'Expression relationship was successfully created.' }
        format.json { render json: @expression_relationship, status: :created, location: @expression_relationship }
      else
        format.html { render action: "new" }
        format.json { render json: @expression_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expression_relationships/1
  # PUT /expression_relationships/1.json
  def update
    @expression_relationship = ExpressionRelationship.find(params[:id])

    respond_to do |format|
      if @expression_relationship.update_attributes(params[:expression_relationship])
        format.html { redirect_to @expression_relationship, notice: 'Expression relationship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @expression_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_relationships/1
  # DELETE /expression_relationships/1.json
  def destroy
    @expression_relationship = ExpressionRelationship.find(params[:id])
    @expression_relationship.destroy

    respond_to do |format|
      format.html { redirect_to expression_relationships_url }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @relationship_types = ExpressionRelationshipType.all
  end
end
