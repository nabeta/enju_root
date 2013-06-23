class CorporateBodiesController < ApplicationController
  # GET /corporate_bodies
  # GET /corporate_bodies.json
  def index
    @corporate_bodies = CorporateBody.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @corporate_bodies }
    end
  end

  # GET /corporate_bodies/1
  # GET /corporate_bodies/1.json
  def show
    @corporate_body = CorporateBody.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @corporate_body }
    end
  end

  # GET /corporate_bodies/new
  # GET /corporate_bodies/new.json
  def new
    @corporate_body = CorporateBody.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @corporate_body }
    end
  end

  # GET /corporate_bodies/1/edit
  def edit
    @corporate_body = CorporateBody.find(params[:id])
  end

  # POST /corporate_bodies
  # POST /corporate_bodies.json
  def create
    @corporate_body = CorporateBody.new(params[:corporate_body])

    respond_to do |format|
      if @corporate_body.save
        format.html { redirect_to @corporate_body, notice: 'Corporate body was successfully created.' }
        format.json { render json: @corporate_body, status: :created, location: @corporate_body }
      else
        format.html { render action: "new" }
        format.json { render json: @corporate_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /corporate_bodies/1
  # PUT /corporate_bodies/1.json
  def update
    @corporate_body = CorporateBody.find(params[:id])

    respond_to do |format|
      if @corporate_body.update_attributes(params[:corporate_body])
        format.html { redirect_to @corporate_body, notice: 'Corporate body was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @corporate_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /corporate_bodies/1
  # DELETE /corporate_bodies/1.json
  def destroy
    @corporate_body = CorporateBody.find(params[:id])
    @corporate_body.destroy

    respond_to do |format|
      format.html { redirect_to corporate_bodies_url }
      format.json { head :no_content }
    end
  end
end
