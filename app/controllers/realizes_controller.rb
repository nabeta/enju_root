class RealizesController < ApplicationController
  # GET /realizes
  # GET /realizes.json
  def index
    @realizes = Realize.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @realizes }
    end
  end

  # GET /realizes/1
  # GET /realizes/1.json
  def show
    @realize = Realize.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @realize }
    end
  end

  # GET /realizes/new
  # GET /realizes/new.json
  def new
    @realize = Realize.new
    @person = Person.find(params[:person_id]) if params[:person_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @realize.person = @person
    @realize.expression = @expression

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @realize }
    end
  end

  # GET /realizes/1/edit
  def edit
    @realize = Realize.find(params[:id])
  end

  # POST /realizes
  # POST /realizes.json
  def create
    @realize = Realize.new(params[:realize])

    respond_to do |format|
      if @realize.save
        format.html { redirect_to @realize, notice: 'Realize was successfully created.' }
        format.json { render json: @realize, status: :created, location: @realize }
      else
        format.html { render action: "new" }
        format.json { render json: @realize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /realizes/1
  # PUT /realizes/1.json
  def update
    @realize = Realize.find(params[:id])

    respond_to do |format|
      if @realize.update_attributes(params[:realize])
        format.html { redirect_to @realize, notice: 'Realize was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @realize.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /realizes/1
  # DELETE /realizes/1.json
  def destroy
    @realize = Realize.find(params[:id])
    @realize.destroy

    respond_to do |format|
      format.html { redirect_to realizes_url }
      format.json { head :no_content }
    end
  end
end
