class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_event
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if !user_access_token.blank?
      user = User.find_by_id(user_access_token.user_id)
      event = params[:event]
      new_event=Event.new
      new_event.event_name = event[:event_name]
      new_event.start_date = event[:start_date]
      new_event.end_date = event[:end_date]
      new_event.description = event[:description]
      new_event.latitude = event[:latitude]
      new_event.longitude = event[:longitude]
      new_event.address= event[:address]
      new_event.private= event[:private]
      new_event.remainder= event[:remainder]
      new_event.status= "Created"
      new_event.owner_id = user.id
      new_event.save
      if request.format == 'json'
        render :json => {:id => new_event.id, :status => new_event.status}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end
  end

  def create_invitations
    participant_mobile_numbers = params[:parcipant_mobile_numbers]
    participant_mobile_numbers= participant_mobile_numbers.to_a
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user_invitation = User.find_by_id(user_access_token.user_id)
    participant_mobile_numbers.each do |participant_mobile_number|
      invitation = Invitation.new
      user=User.find_by_phone_number(participant_mobile_number)
      invitation.event_id = params[:event_id]
      invitation.participant_id = user.id
      invitation.save

    end

    invitation = Invitation.new
    invitation.event_id = params[:event_id]
    invitation.participant_id = user_invitation.id
    invitation.save

    if request.format == 'json'
      render :json => {:status => 'Success'}
    end
  end

  def get_my_invitations
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    invitation =Invitation.find_all_by_participant_id(user.id)
    if request.format == 'json'
      render :json => {:invitation => invitation}
    end
  end

  def get_my_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    events = Event.find_all_by_owner_id(user.id)
    if request.format == 'json'
      render :json => {:events => events}
    end

  end

  def post_location
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    user_location=UserLocation.new
    user_location.user_id=user.id
    user_location.latitude = params[:latitude]
    user_location.longitude = params[:longitude]
    user_location.time= params[:time]
    user_loaction.save
    if request.format == 'json'
      render :json => {:status => "Success"}
    end
  end

  def get_participants_locations
    invitations= Invitation.find_all_by_event_id(params[:event_id])
    invitees_locations = []
    invitations.each do |invitation|
      user_location =UserLocation.where('user_id=?', invitation.participant_id).last
      invitees_locations << user_location if user_location.present?
    end
    if request.format == 'json'
      render :json => {:locations_of_invitees => invitees_locations}
    end
  end

  def accept_or_reject_invitation
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    invitation_details =Invitation.find_by_event_id_and_participant_id(params[:event_id], user.id)
    invitation_details.is_accepted=params[:accepted]
    invitation_details.save
    if request.format == 'json'
      if invitation_details.is_accepted
        render :json => {:status => "Invitation successfully created"}
      else
        render :json => {:status => "Please create the invitation"}
      end
    end
  end


  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
end
