class EmbodiesController < ApplicationController
  before_filter :prepare_options, :only => [:new, :edit]
  # GET /embodies
  # GET /embodies.json
  def index
    @embodies = Embody.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @embodies }
    end
  end

  # GET /embodies/1
  # GET /embodies/1.json
  def show
    @embody = Embody.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @embody }
    end
  end

  # GET /embodies/new
  # GET /embodies/new.json
  def new
    @embody = Embody.new
    @embody.manifestation_url = params[:manifestation_url]
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @embody.manifestation = @manifestation
    @embody.expression = @expression

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @embody }
    end
  end

  # GET /embodies/1/edit
  def edit
    @embody = Embody.find(params[:id])
  end

  # POST /embodies
  # POST /embodies.json
  def create
    @embody = Embody.new(params[:embody])
    manifestation = Manifestation.new(:url => @embody.manifestation_url)
    @embody.manifestation = manifestation

    respond_to do |format|
      if @embody.save
        format.html { redirect_to @embody, notice: 'Embodiment was successfully created.' }
        format.json { render json: @embody, status: :created, location: @embody }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @embody.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /embodies/1
  # PUT /embodies/1.json
  def update
    @embody = Embody.find(params[:id])

    respond_to do |format|
      if @embody.update_attributes(params[:embody])
        format.html { redirect_to @embody, notice: 'Embodiment was successfully updated.' }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @embody.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /embodies/1
  # DELETE /embodies/1.json
  def destroy
    @embody = Embody.find(params[:id])
    @embody.destroy

    respond_to do |format|
      format.html { redirect_to embodies_url }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @relationship_types = ManifestationRelationshipType.all
  end
end
