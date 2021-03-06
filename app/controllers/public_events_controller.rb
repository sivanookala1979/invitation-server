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
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_events = PublicEvent.where('is_active =?', true).order('created_at ASC')
    @public_events = []
    if user.present? && public_events.present?
    public_events.each do |event|
      @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
      if @canceled_public_event.blank?
        city = City.find_by_id(event.city_id).try(:name)
        service = Service.find_by_id(event.service_id).try(:name)
        img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
        is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
        @public_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
      end
    end
    end
    respond_to do |format|
      if params[:trending].present?
        format.json { render :json => {:public_events => @public_events.sort_by { |i| i.views }.reverse!} }
      else
        format.json { render :json => {:public_events => @public_events} }
      end

    end
  end

  def trending_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    city = City.find_by_id(params[:city_id]) if params[:city_id].present?
    if user.present? && city.present?
      public_events = PublicEvent.where("city_id=? and is_active =?", city.id, true)
      @public_events = []
      public_events.each do |event|
        @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
        if @canceled_public_event.blank?
          city = City.find_by_id(event.city_id).try(:name)
          service = Service.find_by_id(event.service_id).try(:name)
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
          @public_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
        end
      end
    end
    respond_to do |format|
      if user.present? && city.present?
        format.json { render :json => {:public_events => @public_events.sort_by { |i| i.views }.reverse!} }
      else
        format.json { render :json => {:error_message => "Please try again."} }
      end
    end
  end

  def add_favourite_event
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_event = PublicEvent.find_by_id(params[:public_event_id]) if params[:public_event_id].present?
    city = City.find_by_id(params[:city_id]) if params[:city_id].present?
    if user.present? && public_event.present? && city.present?
      @favourite = Favourites.find_by_event_id_and_city_id_and_user_id(public_event.id, city.id, user.id)
      if @favourite.blank?
        @favourite = Favourites.new
        @favourite.user_id = user.id
        @favourite.city_id = city.id
        @favourite.event_id = public_event.id
        @favourite.save
      end
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
      favourites = Favourites.where('user_id =? and city_id =?', user.id, params[:city_id])
      @favourite_events = []
      favourites.each do |favourite|
        @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(favourite.event_id, user.id)
        if @canceled_public_event.blank?
          event = PublicEvent.find_by_id(favourite.event_id)
          if event.present?
            city = City.find_by_id(event.city_id).try(:name)
            service = Service.find_by_id(event.service_id).try(:name)
            img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
            is_favourite = user.present? && (fav = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
            @favourite_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
          end
        end
      end
    end
    respond_to do |format|
      if user.present?
        format.json { render :json => {:favourite_events => @favourite_events} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def free_public_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?

    public_events = PublicEvent.where('is_active =? and entry_fee=? and city_id=?', true, 0.0, params[:city_id]) if params[:city_id].present?
    @free_events = []
    if public_events.present?
      public_events.each do |event|
        @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
        if @canceled_public_event.blank?
          city = City.find_by_id(event.city_id).try(:name)
          service = Service.find_by_id(event.service_id).try(:name)
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
          @free_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
        end
      end
    end
    respond_to do |format|
      format.json { render :json => {:free_events => @free_events} }
    end
  end

  def public_events_with_search_keywords
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_events = PublicEvent.where('is_active =? and city_id=? and keyword1 in(?) or keyword2 in(?) or keyword3 in(?) or keyword4 in(?) or keyword5 in(?)   or event_name in(?) or address in(?) ', true, params[:city_id], params[:keywords].split(','), params[:keywords].split(','), params[:keywords].split(','), params[:keywords].split(','), params[:keywords].split(','), params[:keywords].split(','), params[:keywords].split(',')) if params[:city_id].present? && params[:keywords].present?
    @searched_events = []
    if user.present? && public_events.present?
      public_events.each do |event|
        @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
        if @canceled_public_event.blank?
          city = City.find_by_id(event.city_id).try(:name)
          service = Service.find_by_id(event.service_id).try(:name)
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
          @searched_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
        end
      end
    end
    respond_to do |format|
      if user.present?
        format.json { render :json => {:searched_events => @searched_events} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def weekend_public_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_events = PublicEvent.where('is_active =? and is_weekend=? and city_id=?', true, true, params[:city_id]) if params[:city_id].present?
    @weekend_events = []
    if public_events.present?
      public_events.each do |event|
        @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
        if @canceled_public_event.blank?
          city = City.find_by_id(event.city_id).try(:name)
          service = Service.find_by_id(event.service_id).try(:name)
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
          @weekend_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
        end
      end
    end
    respond_to do |format|
      format.json { render :json => {:weekend_events => @weekend_events} }
    end
  end

  def remove_favourite_event
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    public_event = PublicEvent.find_by_id(params[:public_event_id]) if params[:public_event_id].present?
    city = City.find_by_id(params[:city_id]) if params[:city_id].present?
    if user.present?&& public_event.present?&& city.present?
      @favourite = Favourites.find_by_event_id_and_city_id_and_user_id(public_event.id, city.id, user.id)
      @favourite.destroy if @favourite.present?
    end
    respond_to do |format|
      if user.present? && public_event.present? && city.present?
        format.json { render :json => {:status => "Updated successfully"} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def add_views
    @public_event = PublicEvent.find_by_id(params[:public_event_id])
    @public_event.update_attribute(:views, @public_event.views + 1) if @public_event.present?
    respond_to do |format|
      if @public_event.present?
        format.json { render :json => {:status => "Updated successfully"} }
      else
        format.json { render :json => {:error_message => "Please try again."} }
      end
    end
  end

  def cancel_public_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @public_event = PublicEvent.find_by_id(params[:public_event_id]) if params[:public_event_id].present?
    if user.present? && @public_event.present?
      @canceled_public_event = CanceledPublicEvents.new
      @canceled_public_event.canceled_user_id = user.id
      @canceled_public_event.authour_id = 0;
      @canceled_public_event.event_id = @public_event.id
      @canceled_public_event.save
    end
    respond_to do |format|
      if @canceled_public_event.present?
        format.json { render :json => {:status => "Updated successfully"} }
      else
        format.json { render :json => {:error_message => "Please try again."} }
      end
    end
  end

  def similar_events_list
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @public_event = PublicEvent.find_by_id(params[:public_event_id]) if params[:public_event_id].present?
    if @public_event.present? && @public_event.service_id.present? && user.present? && params[:city_id].present?
      similar_events_list = []
      public_events = PublicEvent.find_all_by_service_id_and_city_id(@public_event.service_id,params[:city_id])
      if public_events.present?
        public_events.each do |event|
          @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
          if @canceled_public_event.blank? && !@public_event.id.eql?(event.id)
            city = City.find_by_id(event.city_id).try(:name)
            service = Service.find_by_id(event.service_id).try(:name)
            img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
            is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
            similar_events_list << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
          end
        end
      end
    end
    respond_to do |format|
      if @public_event.present? && @public_event.service_id.present? && user.present? && params[:city_id].present?
        format.json { render :json => {:similar_events_list => similar_events_list} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def recommended_events_list
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if user.present? && params[:city_id].present?
      public_events = PublicEvent.find_all_by_city_id_and_is_recommended(params[:city_id], true)
      recommended_events_list = []
      if public_events.present?
        public_events.each do |event|
          @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
          if @canceled_public_event.blank?
            city = City.find_by_id(event.city_id).try(:name)
            service = Service.find_by_id(event.service_id).try(:name)
            img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
            is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
            recommended_events_list << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee,event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
          end
        end
      end
    end
    respond_to do |format|
      if user.present? && params[:city_id].present?
        format.json { render :json => {:recommended_events_list => recommended_events_list} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def offered_public_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if user.present? && params[:city_id].present?
      public_events = PublicEvent.where("city_id=? and offer_amount >?", params[:city_id], 0.0)
      offered_public_events = []
      if public_events.present?
        public_events.each do |event|
          @canceled_public_event = CanceledPublicEvents.find_by_event_id_and_canceled_user_id(event.id, user.id)
          if @canceled_public_event.blank?
            city = City.find_by_id(event.city_id).try(:name)
            service = Service.find_by_id(event.service_id).try(:name)
            img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
            is_favourite = user.present? && (favourite = Favourites.find_by_event_id_and_user_id(event.id, user.id)).present? ? true : false
            offered_public_events << PublicEventsList.new(event.id, event.event_name, event.event_theme, event.start_time, event.end_time, event.entry_fee, event.offer_amount, event.description, event.address,event.latitude,event.longitude, event.is_weekend, city, service, img_url, is_favourite, event.views)
          end
        end
      end
    end
    respond_to do |format|
      if user.present? && params[:city_id].present?
        format.json { render :json => {:offered_public_events => offered_public_events} }
      else
        format.json { render :json => {:error_message => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end


end
