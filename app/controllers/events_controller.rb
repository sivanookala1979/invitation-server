class EventsController < ApplicationController
  include EventsHelper
  include ApplicationHelper
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
    respond_to do |format|
      format.html # index.html.erb
      format.js
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
      new_event =Event.find_by_id(params[:event_id]) if params[:event_id].present?
      new_event=Event.new if new_event.blank?
      new_event.event_name = event[:event_name]
      puts event[:start_date]
      new_event.start_date = Time.parse(event[:start_date]).utc.in_time_zone('Kolkata')
      puts new_event.start_date
      puts event[:end_date]
      new_event.end_date = Time.parse(event[:end_date]).utc.in_time_zone('Kolkata')
      puts new_event.end_date
      new_event.description = event[:description]
      new_event.latitude = event[:latitude]
      new_event.longitude = event[:longitude]
      new_event.address= event[:address]
      new_event.private= event[:private]
      new_event.remainder= event[:remainder]
      new_event.is_manual_check_in= event[:is_manual_check_in]
      new_event.is_recurring_event=event[:is_recurring_event]
      new_event.recurring_type=event[:recurring_type]
      new_event.event_theme=event[:event_theme]
      new_event.hide=false
      new_event.check_in_count = 0
      new_event.status= "Created" if params[:event_id].blank?
      new_event.owner_id = user.id
      new_event.save
      if request.format == 'json'
        render :json => {:id => new_event.id, :status => params[:event_id].present? ? new_event.status : 'Successfully Updated.'}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end
  end

  def delete_event
    event = Event.find_by_id(params[:event_id])
    event.hide = true
    event.save
    if request.format == 'json'
      render :json => {:id => event.id, :status => 'Event Successfully deleted'}
    end
  end

  def create_invitations
    participant_mobile_numbers = params[:participant_mobile_numbers]
    participant_mobile_numbers= participant_mobile_numbers.to_a
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user_invitation = User.find_by_id(user_access_token.user_id)
    event_invitation = Event.find_by_id(params[:event_id])
    group_ids =params[:group_ids].to_a
    if group_ids.present?
      group_ids.each do |group_id|
        group = Group.find_by_id(group_id.to_i)
        group_numbers = group.contact_numbers.split(',')
        group_numbers.each do |group_number|
          participant = User.find_by_phone_number(group_number)
          if participant.present?
            invitation = Invitation.find_by_participant_id_and_participant_mobile_number(participant.id, group_number)
            if invitation.blank?
              invitation = Invitation.new
              invitation.participant_id = participant.id
              invitation.participant_mobile_number = participant.phone_number
              invitation.save
            end
          else
            invitation = Invitation.new
            invitation.participant_mobile_number = group_number
          end
          event_invitation.invitees_count = 0 if event_invitation.invitees_count.blank?
          invitation.event_id = event_invitation.id
          event_invitation.invitees_count = event_invitation.invitees_count+1
          invitation.save
        end
      end
    end

    participant_mobile_numbers.each do |participant_mobile_number|
      user=User.find_by_phone_number(participant_mobile_number)
      if user.present?
        invitation =Invitation.find_by_event_id_and_participant_id(params[:event_id], user.id)
        if invitation.blank?
          invitation = Invitation.new
          invitation.participant_id = user.id
          invitation.participant_mobile_number=participant_mobile_number
        end
      else
        invitation = Invitation.new
        invitation.participant_mobile_number=participant_mobile_number
      end
      invitation.event_id = event_invitation.id
      event_invitation.invitees_count = event_invitation.invitees_count+1
      invitation.save
    end
    if request.format == 'json'
      render :json => {:status => 'Success'}
    end
  end

  def get_my_invitations
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if user_access_token.present?
      user = User.find_by_id(user_access_token.user_id)
      invitation =Invitation.find_all_by_participant_id(user.id)
      if request.format == 'json'
        render :json => {:invitation => invitation}
      end
    else
      render :json => {:status => 'Invalid User Details'}
    end
  end

  def get_my_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if user_access_token.present?
      user = User.find_by_id(user_access_token.user_id)
      if !params[:event_ids].blank?
        all_my_events = Event.where('id in (?)', params[:event_ids].split(', '))
      else
        all_my_events = Event.find_all_by_owner_id(user.id)
      end
      invitations =Invitation.find_all_by_participant_id(user.id)
      all_my_events << Event.where('id in(?)', invitations.collect{|invitation| invitation.event_id})
    end
    if request.format == 'json'
      if user_access_token.present?
        render :json => {:events => all_my_events}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
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
    user_location.user_name= user.user_name
    user_location.user_mobile_number = user.phone_number
    user_location.save
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
    is_accepted_count=0
    is_rejected_count=0
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    invitation_details =Invitation.find_by_event_id_and_participant_id(params[:event_id], user.id)
    event_invitation = Event.find_by_id(params[:event_id])
    event_invitation.accepted_count = 0 if event_invitation.accepted_count.blank?
    event_invitation.rejected_count = 0 if event_invitation.rejected_count.blank?
    invitation_details.is_accepted=params[:accepted]
    if (invitation_details.is_accepted.eql?(true))
      event_invitation.accepted_count =event_invitation.accepted_count+1
    else
      event_invitation.rejected_count = event_invitation.rejected_count+1
    end
    event_invitation.save
    invitation_details.save
    if request.format == 'json'
      if invitation_details.is_accepted
        render :json => {:status => "Invitation Accepterd"}
      else
        render :json => {:status => "Invitation Rejected"}
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

  def event_invitations
    event = Event.find(params[:id])
    update_auto_checkIn_status(event)
    @event_invitation = Invitation.find_all_by_event_id(params[:id])
    if params[:status].present?
      if params[:status].eql?('CheckIn')
        @event_invitation = Invitation.find_all_by_event_id_and_is_check_in(params[:id], params[:status].eql?('CheckIn'))
      elsif params[:status].eql?('Pending')
        @event_invitation = Invitation.find_all_by_event_id_and_is_accepted_and_is_check_in(params[:id], true, false)
      elsif params[:status].eql?('NotGoing')
        @event_invitation = Invitation.find_all_by_event_id_and_is_accepted(params[:id], false)
      end
    end
    @invitees_size = @event_invitation.size
    invitation_details_list=[]
    @event_invitation.each do |invitation|
      invitation_details = InvitationDetails.new
      invitation_details.is_accepted=invitation.is_accepted
      user = User.find_by_id(invitation.participant_id)
      user = User.find_by_phone_number(invitation.participant_mobile_number) if user.blank?
      if user.present?
      invitation_details.name=user.user_name
      invitation_details.mobile=user.phone_number
      user_location = UserLocation.where('user_id=?', user.id).last
      if user_location.present?
        invitation_details.distance= getDistanceFromLatLonInKm(event.latitude, event.longitude, user_location.latitude, user_location.longitude)
        invitation_details.update_at=distance_of_time_in_words(user_location.time, Time.now)
      end
      invitation_details_list<<invitation_details
      end
    end
    if request.format == 'json'
      render :json => {:participants_list => invitation_details_list}
    end
  end

  def update_auto_checkIn_status(event)
    if !event.is_manual_check_in
      if event.start_date>Time.now
        event_invitations = Invitation.find_all_by_event_id_and_is_check_in_and_is_accepted(params[:id], false, true)
        event_invitations.each do |invitation|
          user_location = UserLocation.where('user_id=?', invitation.participant_id).last
          if user_location.present?
            distance = getDistanceFromLatLonInKm(event.latitude, event.longitude, user_location.latitude, user_location.longitude)
            if distance<1
              invitation.is_check_in=true
              event.check_in_count=0 if event.check_in_count.blank?
              event.check_in_count =event.check_in_count+1
              event.save
              invitation.save
            end
          end
        end
      end
    end
  end

  def user_locations
    @user_locations = UserLocation.find_all_by_user_id(params[:participant_id])
  end

  def event_user_locations
    @event_invitations = Invitation.find_all_by_event_id(params[:event_id])
    @event_user_locations = []
    @event_invitations.each do |invitation|
      user_location = UserLocation.where('user_id=?', invitation.participant_id).last
      @event_user_locations << user_location if user_location.present?
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

  def invitee_check_in_Status
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    event = Event.find(params[:id])
    invitation = Invitation.find_by_event_id_and_participant_id(event.id, user.id)
    if invitation.present?
      if params[:status].eql?('CheckIn')
        invitation.is_check_in=true
        event.check_in_count=0 if event.check_in_count.blank?
        event.check_in_count=event.check_in_count+1
        event.save
      elsif params[:status].eql?('NotGoing')
        invitation.is_accepted=false
      end
      invitation.save
    end
    if request.format == 'json'
      render :json => {:status => invitation.present? ? 'Success' : 'FAILED'}
    end
  end

  def get_distance_from_event
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    user = User.find_by_id(user_access_token.user_id)
    event = Event.find(params[:event_id])
    user_location = UserLocation.where('user_id = ?', user.id).last
    if request.format == 'json'
      if user_location.present?
        render :json => {:status => 'Success', :distance => getDistanceFromLatLonInKm(event.latitude, event.longitude, user_location.latitude, user_location.longitude)}
      else
        render :json => {:status => 'Failed to get distance.'}
      end
    end

  end
end
