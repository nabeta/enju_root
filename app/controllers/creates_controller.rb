class CreatesController < ApplicationController
  # GET /creates
  # GET /creates.json
  def index
    @creates = Create.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @creates }
    end
  end

  # GET /creates/1
  # GET /creates/1.json
  def show
    @create = Create.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @create }
    end
  end

  # GET /creates/new
  # GET /creates/new.json
  def new
    @create = Create.new
    @person = Person.find(params[:person_id]) if params[:person_id]
    @work = Work.find(params[:work_id]) if params[:work_id]
    @create.person = @person
    @create.work = @work

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @create }
    end
  end

  # GET /creates/1/edit
  def edit
    @create = Create.find(params[:id])
  end

  # POST /creates
  # POST /creates.json
  def create
    @create = Create.new(params[:create])

    respond_to do |format|
      if @create.save
        format.html { redirect_to @create, notice: 'Create was successfully created.' }
        format.json { render json: @create, status: :created, location: @create }
      else
        format.html { render action: "new" }
        format.json { render json: @create.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /creates/1
  # PUT /creates/1.json
  def update
    @create = Create.find(params[:id])

    respond_to do |format|
      if @create.update_attributes(params[:create])
        format.html { redirect_to @create, notice: 'Create was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @create.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /creates/1
  # DELETE /creates/1.json
  def destroy
    @create = Create.find(params[:id])
    @create.destroy

    respond_to do |format|
      format.html { redirect_to creates_url }
      format.json { head :no_content }
    end
  end
end
