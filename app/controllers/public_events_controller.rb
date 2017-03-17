class PublicEventsController < ApplicationController
  # GET /public_events
  # GET /public_events.json
  def index
    @public_events = PublicEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @public_events }
    end
  end

  # GET /public_events/1
  # GET /public_events/1.json
  def show
    @public_event = PublicEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @public_event }
    end
  end

  # GET /public_events/new
  # GET /public_events/new.json
  def new
    @public_event = PublicEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @public_event }
    end
  end

  # GET /public_events/1/edit
  def edit
    @public_event = PublicEvent.find(params[:id])
  end

  # POST /public_events
  # POST /public_events.json
  def create
    @public_event = PublicEvent.new(params[:public_event])
    upload_image
    respond_to do |format|
      if @public_event.save
        format.html { redirect_to "/public_events", notice: 'Public event was successfully created.' }
        format.json { render json: @public_event, status: :created, location: @public_event }
      else
        format.html { render action: "new" }
        format.json { render json: @public_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /public_events/1
  # PUT /public_events/1.json
  def update
    @public_event = PublicEvent.find(params[:id])

    respond_to do |format|
      if @public_event.update_attributes(params[:public_event])
        upload_image
        @public_event.save
        format.html { redirect_to "/public_events", notice: 'Public event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @public_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_image
    if params[:public_event][:image_id].present?
      image = ApplicationHelper.upload_image(params[:city][:image_id])
      @public_event.update_attribute(:image_id, image.id)
    end
  end

  # DELETE /public_events/1
  # DELETE /public_events/1.json
  def destroy
    @public_event = PublicEvent.find(params[:id])
    @public_event.destroy

    respond_to do |format|
      format.html { redirect_to public_events_url }
      format.json { head :ok }
    end
  end
end
