# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  # GET /manifestations
  # GET /manifestations.json
  def index
    @query = params[:query]
    @expression = expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestations = Manifestation.search do
      #with(:course).equal_to "国語"
      if params[:mode] != 'add'
        with(:expression_ids).equal_to expression.id if expression
      end
      fulltext params[:query]
      paginate :page => params[:page], :per_page => Manifestation.default_per_page
    end.results

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @manifestations }
    end
  end

  # GET /manifestations/1
  # GET /manifestations/1.json
  def show
    if params[:bib_id].present?
      @manifestation = Manifestation.where(:bib_id => params[:bib_id]).first
      raise ActiveRecord::RecordNotFound unless @manifestation
    else
      @manifestation = Manifestation.find(params[:id])
    end
    @catalogs = Catalog.all

    respond_to do |format|
      format.html # show.html.erb
      format.json #{ render json: @manifestation }
    end
  end

  # GET /manifestations/new
  # GET /manifestations/new.json
  def new
    @manifestation = Manifestation.new(params[:manifestation])
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestation.expression_id = @expression.id if @expression

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @manifestation }
    end
  end

  # GET /manifestations/1/edit
  def edit
    @manifestation = Manifestation.find(params[:id])
  end

  # POST /manifestations
  # POST /manifestations.json
  def create
    @manifestation = Manifestation.new(params[:manifestation])

    respond_to do |format|
      if @manifestation.save
        if @manifestation.expression_id.present?
          expression = Expression.find(@manifestation.expression_id)
          @manifestation.expressions << expression if expression
        end
        format.html { redirect_to @manifestation, notice: 'Manifestation was successfully created.' }
        format.json { render json: @manifestation, status: :created, location: @manifestation }
      else
        format.html { render action: "new" }
        format.json { render json: @manifestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /manifestations/1
  # PUT /manifestations/1.json
  def update
    @manifestation = Manifestation.find(params[:id])

    respond_to do |format|
      if @manifestation.update_attributes(params[:manifestation])
        format.html { redirect_to @manifestation, notice: 'Manifestation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @manifestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestations/1
  # DELETE /manifestations/1.json
  def destroy
    @manifestation = Manifestation.find(params[:id])
    @manifestation.destroy

    respond_to do |format|
      format.html { redirect_to manifestations_url }
      format.json { head :no_content }
    end
  end
end
