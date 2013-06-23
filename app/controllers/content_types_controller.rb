class ContentTypesController < ApplicationController
  # GET /content_types
  # GET /content_types.json
  def index
    @content_types = ContentType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @content_types }
    end
  end

  # GET /content_types/1
  # GET /content_types/1.json
  def show
    @content_type = ContentType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @content_type }
    end
  end

  # GET /content_types/new
  # GET /content_types/new.json
  def new
    @content_type = ContentType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @content_type }
    end
  end

  # GET /content_types/1/edit
  def edit
    @content_type = ContentType.find(params[:id])
  end

  # POST /content_types
  # POST /content_types.json
  def create
    @content_type = ContentType.new(params[:content_type])

    respond_to do |format|
      if @content_type.save
        format.html { redirect_to @content_type, notice: 'Content type was successfully created.' }
        format.json { render json: @content_type, status: :created, location: @content_type }
      else
        format.html { render action: "new" }
        format.json { render json: @content_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /content_types/1
  # PUT /content_types/1.json
  def update
    @content_type = ContentType.find(params[:id])

    respond_to do |format|
      if @content_type.update_attributes(params[:content_type])
        format.html { redirect_to @content_type, notice: 'Content type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @content_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /content_types/1
  # DELETE /content_types/1.json
  def destroy
    @content_type = ContentType.find(params[:id])
    @content_type.destroy

    respond_to do |format|
      format.html { redirect_to content_types_url }
      format.json { head :no_content }
    end
  end
end
