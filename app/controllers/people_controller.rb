class PeopleController < ApplicationController
  # GET /people
  # GET /people.json
  def index
    @work = work = Work.find(params[:work_id]) if params[:work_id]
    @expression = expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestation = manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @people = Person.search do
      unless params[:mode] == 'add'
        with(:work_ids).equal_to work.id if work
        with(:expression_ids).equal_to expression.id if expression
        with(:manifestation_ids).equal_to manifestation.id if manifestation
      end
      fulltext params[:query]
      paginate :page => params[:page]
    end.results

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new
    @work = Work.find(params[:work_id]) if params[:work_id]
    @expression = Expression.find(params[:expression_id]) if params[:expression_id]
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    @person.work_id = @work.id if @work
    @person.expression_id = @expression.id if @expression
    @person.manifestation_id = @manifestation.id if @manifestation

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])
    work = Work.find(@person.work_id) if @person.work_id.present?
    expression = Expression.find(@person.expression_id) if @person.expression_id.present?
    manifestation = Manifestation.find(@person.manifestation_id) if @person.manifestation_id.present?

    respond_to do |format|
      if @person.save
        if work
          @person.works << work
        end
        if expression
          @person.expressions << expression
        end
        if manifestation
          @person.manifestations << manifestation
        end
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end
end
