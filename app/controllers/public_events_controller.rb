class PublicEventsController < ApplicationController
  # GET /public_events
  # GET /public_events.json
  include PublicEventsHelper
  include ApplicationHelper
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
      image = ApplicationHelper.upload_image(params[:public_event][:image_id])
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


  def get_public_events
    public_events = PublicEvent.where('is_active =?', true).order('created_at ASC')
    @public_events = []
    public_events.each do |event|
      city = City.find_by_id(event.city_id).try(:name)
      service = Service.find_by_id(event.service_id).try(:name)
      img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
      @public_events << PublicEventsList.new(event.id,event.event_name,event.event_theme,event.start_time,event.end_time,event.entry_fee,event.description,event.address,event.is_weekend,city,service,img_url)
    end
    respond_to do |format|
      format.json { render :json => {:public_events => @public_events} }
    end
  end

  def add_favourites
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_event = PublicEvent.find_by_id_id(params[:public_event_id]) if params[:public_event_id].present?
    city = City.find_by_id(params[:city_id]) if params[:city_id].present?
    if user.present? && public_event.present? && city.present?
      @favourite = Favourites.new
      @favourite.user_id = user.id
      @favourite.city_id = city.id
      @favourite.event_id = public_event.id
      @favourite.save
    end

    respond_to do |format|
      if @favourite.present?
        format.json { render :json => {:status => "successfully  added"} }
      else
        format.json { render :json => {:error_message => "Please try again."} }
      end
    end
  end

  def my_city_favourites
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if user.present? && params[:city_id].present?
      favourites = Favourites.where('user_id =? and city_id =?', user.id.params[:city_id])
      @favourite_events = []
      favourites.each do |event|
        city = City.find_by_id(event.city_id).try(:name)
        service = Service.find_by_id(event.service_id).try(:name)
        img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
        @favourite_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee, event.description, event.address, event.is_weekend, city, service, img_url)
      end
    end
    respond_to do |format|
      if user.present?
        format.json { render :json => {:public_events => @favourite_events} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

end
