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
    if user_access_token.present?
      user = User.find_by_id(user_access_token.user_id)
      event = params[:event]
      new_event =Event.find_by_id(params[:event_id]) if params[:event_id].present?
      new_event=Event.new if new_event.blank?
      new_event.event_name = event[:event_name]
      new_event.start_date = Time.parse(event[:start_date]).utc.in_time_zone('Kolkata')
      new_event.end_date = Time.parse(event[:end_date]).utc.in_time_zone('Kolkata')
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
      if params[:image].present?
        image = save_image(params[:image])
        new_event.update_attribute(:image_id, image.id) if image.present?
      end
      new_event.save
      event_admin = EventAdmins.find_by_user_id_and_event_id(new_event.owner_id, new_event.id)
      if event_admin.blank?
        event_admins = EventAdmins.new
        event_admins.event_id = new_event.id
        event_admins.user_id = new_event.owner_id
        event_admins.save
      end
      notification(new_event.owner_id, new_event.id, "Your event is created with the name #{new_event.event_name}.")
    end
    if request.format == 'json'
      if user_access_token.present?
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
            end
          else
            user = User.new
            user.user_name = group_number
            user.phone_number = group_number
            user.save
            user_access_token = UserAccessTokens.find_by_user_id(user.id)
            if user_access_token.blank?
              user_access_token = UserAccessTokens.new
              user_access_token.user_id = user.id
              user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
              user_access_token.save
            end
            invitation = Invitation.new
            invitation.participant_id = user.id
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
        user = User.new
        user.user_name = participant_mobile_number
        user.phone_number = participant_mobile_number
        user.save
        user_access_token = UserAccessTokens.find_by_user_id(user.id)
        if user_access_token.blank?
          user_access_token = UserAccessTokens.new
          user_access_token.user_id = user.id
          user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
          user_access_token.save
        end
        invitation = Invitation.new
        invitation.participant_id = user.id
        invitation.participant_mobile_number=participant_mobile_number
      end
      invitation.event_id = event_invitation.id
      event_invitation.invitees_count = 0 if event_invitation.invitees_count.blank?
      event_invitation.invitees_count = event_invitation.invitees_count+1
      invitation.save
    end
    event_invitation.save
    if request.format == 'json'
      render :json => {:status => 'Success', :total_invites=>event_invitation.invitees_count}
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
        events = Event.where('id in (?)', params[:event_ids].split(', ')).order('start_date DESC')
        all_my_events = []
        events.each do |event|
          @event_admin = EventAdmins.find_by_user_id_and_event_id(user.id, event.id)
          is_admin = @event_admin.present? ? true : false
          invitation = Invitation.find_by_event_id_and_participant_id(event.id, user.id)
          is_accepted = invitation.present? && invitation.is_accepted.present? ? invitation.is_accepted : false
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          is_expire =  event.end_date <= Time.now
          all_my_events << EventDetails.new(event.id.to_i,event.event_name, event.end_date, event.description, event.latitude, event.longitude, event.address, event.private, event.remainder, event.status, event.owner_id, event.start_date, event.invitees_count, event.accepted_count, event.rejected_count, event.is_manual_check_in, event.check_in_count, event.is_recurring_event, event.recurring_type, event.event_theme, is_accepted,is_admin,img_url,is_expire)
        end
      else
        events = Event.where('owner_id in (?)', user.id).order('start_date DESC')
        all_my_events = []
        events.each do |event|
          @event_admin = EventAdmins.find_by_user_id_and_event_id(user.id, event.id)
          is_admin = @event_admin.present? ? true : false
          invitation = Invitation.find_by_event_id_and_participant_id(event.id, user.id)
          is_accepted = invitation.present? && invitation.is_accepted.present? ? invitation.is_accepted : false
          img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
           is_expire =  event.end_date <= Time.now
          all_my_events << EventDetails.new(event.id.to_i,event.event_name, event.end_date, event.description, event.latitude, event.longitude, event.address, event.private, event.remainder, event.status, event.owner_id, event.start_date, event.invitees_count, event.accepted_count, event.rejected_count, event.is_manual_check_in, event.check_in_count, event.is_recurring_event, event.recurring_type, event.event_theme, is_accepted,is_admin,img_url,is_expire)
        end
      end

    end
    if request.format == 'json'
      if user_access_token.present?
        render :json => {:events => all_my_events}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end

  end

  def get_all_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if user_access_token.present?
      user = User.find_by_id(user_access_token.user_id)
      if !params[:event_ids].blank?
        all_events = Event.where('id in (?) and hide =?', params[:event_ids].split(', '), false)
      else
        all_events = Event.find_all_by_owner_id_and_hide(user.id, false)
        invitations =Invitation.find_all_by_participant_id(user.id)
        all_events << Event.where('id in(?)', invitations.collect { |invitation| invitation.event_id })
        all_events.flatten!
        all_events.uniq!
      end
      all_events.sort! { |a, b| b.start_date <=> a.start_date }
    end

    all_my_events = []
    if all_events.present?
    all_events.each do |event|
      @event_admin = EventAdmins.find_by_user_id_and_event_id(user.id, event.id)
      is_admin = @event_admin.present? ? true : false
      invitation = Invitation.find_by_event_id_and_participant_id(event.id, user.id)
      is_accepted = invitation.present? && invitation.is_accepted.present? ? invitation.is_accepted : false
      img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
      is_expire =  event.end_date <= Time.now
      all_my_events << EventDetails.new(event.id.to_i,event.event_name, event.end_date, event.description, event.latitude, event.longitude, event.address, event.private, event.remainder, event.status, event.owner_id, event.start_date, event.invitees_count, event.accepted_count, event.rejected_count, event.is_manual_check_in, event.check_in_count, event.is_recurring_event, event.recurring_type, event.event_theme, is_accepted,is_admin,img_url,is_expire)
    end
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
    if invitation_details.present?
      invitation_details.is_accepted = params[:accepted]
      if (invitation_details.is_accepted.eql?(true))
        if params[:permission].present?
          invitation_details.update_attribute(:is_location_provide, true) if params[:permission].present? && params[:permission].eql?("LOCATION")
          invitation_details.update_attribute(:is_distance_provide, true) if params[:permission].present? && params[:permission].eql?("DISTANCE")
          invitation_details.update_attribute(:is_not_share, true) if params[:permission].present? && params[:permission].eql?("NOTHING")
          notification(event_invitation.owner_id, event_invitation.id, "Mrs/Ms  #{user.user_name} is Accepted your invitation.")
        end
        event_invitation.accepted_count =event_invitation.accepted_count+1
      else
        invitation_details.update_attribute(:is_rejected,true)
        event_invitation.rejected_count = event_invitation.rejected_count+1
        notification(event_invitation.owner_id, event_invitation.id, "Mrs/Ms  #{user.user_name} is rejected your invitation.")
      end
    end
    event_invitation.save
    invitation_details.save
    if request.format == 'json'
      if invitation_details.is_accepted
        render :json => {:status => "Invitation Accepterd", :accepted_count => event_invitation.accepted_count, :invitees_count => event_invitation.invitees_count, :rejected_count => event_invitation.rejected_count, :check_in_count => event_invitation.check_in_count}
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
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    event = Event.find(params[:id]) if @user.present?
    invitation_details_list=[]
    if event.present?
      update_auto_checkIn_status(event)
      @event_admin = EventAdmins.find_by_event_id_and_user_id(event.id,@user.id)
      if @event_admin.present?
      @event_invitation = Invitation.find_all_by_event_id(event.id)
      if params[:status].present?
        @event_invitation = Invitation.find_all_by_event_id_and_is_check_in(params[:id], params[:status].eql?('CheckIn')) if params[:status].eql?('CheckIn')
        @event_invitation = Invitation.find_all_by_event_id_and_is_accepted_and_is_check_in(params[:id], true, false) if params[:status].eql?('Pending')
        @event_invitation = Invitation.find_all_by_event_id_and_is_accepted(params[:id], false) if params[:status].eql?('NotGoing')
      end
      else
        @event_invitation = Invitation.find_all_by_event_id_and_is_blocked(event.id,false)
        if params[:status].present?
          @event_invitation = Invitation.find_all_by_event_id_and_is_check_in_and_is_blocked(params[:id], params[:status].eql?('CheckIn'),false) if params[:status].eql?('CheckIn')
          @event_invitation = Invitation.find_all_by_event_id_and_is_accepted_and_is_check_in_and_is_blocked(params[:id], true, false,false) if params[:status].eql?('Pending')
          @event_invitation = Invitation.find_all_by_event_id_and_is_accepted_and_is_blocked(params[:id], false,false) if params[:status].eql?('NotGoing')
        end
      end
      @event_invitation.each do |invitation|
        invitation_details = InvitationDetails.new
        invitation_details.is_accepted= invitation.is_accepted ? true : false
        user = User.find_by_id(invitation.participant_id)
        user = User.find_by_phone_number(invitation.participant_mobile_number) if user.blank?
        if user.present?
          invitation_details.name=user.user_name
          invitation_details.mobile=user.phone_number
          invitation_details.user_id = user.id
          user_location = UserLocation.where('user_id=?', user.id).last
          if user_location.present?
            invitation_details.distance= getDistanceFromLatLonInKm(event.latitude, event.longitude, user_location.latitude, user_location.longitude)
            invitation_details.update_at=distance_of_time_in_words(user_location.time, Time.now)
          end
          invitation_details.email = user.email.present? ? user.email : ""
          invitation_details.img_url = (image = Images.find_by_id(user.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          @event_admin = EventAdmins.find_by_event_id_and_user_id(event.id, invitation.participant_id)
          invitation_details.is_admin = @event_admin.present? ? true : false
          invitation_details.is_blocked = invitation.is_blocked
          invitation_details_list<<invitation_details
        end
      end
    end
    if request.format == 'json'
      if @user.present?
        render :json => {:participants_list => invitation_details_list}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
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


  def create_new_invitations
    @event = Event.find_by_id(params[:event_id])
    if @event.present?
      participant_mobile_numbers = params[:participant_mobile_numbers]
      group_ids =params[:group_ids].to_a
      if participant_mobile_numbers.present?
        participant_mobile_numbers.each do |participant_mobile|
          @user = User.find_by_phone_number(participant_mobile['mobile_number'])
          if @user.blank?
            @user = User.new
            @user.user_name = participant_mobile['mobile_number']
            @user.phone_number = participant_mobile['mobile_number']
            @user.save
            user_access_token = UserAccessTokens.find_by_user_id(@user.id)
            if user_access_token.blank?
              user_access_token = UserAccessTokens.new
              user_access_token.user_id = @user.id
              user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
              user_access_token.save
            end
          end
          invitation = Invitation.find_by_participant_id_and_event_id(@user.id, @event.id)
          if invitation.blank?
            invitation = Invitation.new
            invitation.participant_id = @user.id
            invitation.event_id = @event.id
            invitation.participant_mobile_number = participant_mobile['mobile_number']
            invitation.save
            notification(invitation.participant_id, @event.id, "#{User.find_by_id(@event.owner_id).try(:user_name)} sended invitation for his event #{@event.event_name}")
          end
          if participant_mobile["event_admin"].present? && participant_mobile["event_admin"].eql?(true)
            event_admins = EventAdmins.find_by_event_id_and_user_id(@event.id, @user.id)
            if event_admins.blank?
              event_admin = EventAdmins.new
              event_admin.user_id = @user.id
              event_admin.event_id = @event.id
              event_admin.save
            end
          end
          @event.invitees_count = 0 if @event.invitees_count.blank?
          @event.invitees_count = @event.invitees_count.to_i + 1
          @event.save
        end
      end
      if group_ids.present?
        group_ids.each do |group_id|
          @group = Group.find_by_id(group_id.to_i)
          group_numbers = GroupMembers.find_all_by_group_id(@group.id)
          if group_numbers.present?
            group_numbers.each do |number|
              @user = User.find_by_id(number.user_id)
              if @user.blank?
                @user = User.new
                @user.user_name = number.user_name
                @user.phone_number = number.user_mobile_number
                @user.save
                user_access_token = UserAccessTokens.find_by_user_id(@user.id)
                if user_access_token.blank?
                  user_access_token = UserAccessTokens.new
                  user_access_token.user_id = @user.id
                  user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
                  user_access_token.save
                end
              end
              invitation = Invitation.find_by_participant_id_and_event_id(@user.id, @event.id)
              if invitation.blank?
                invitation = Invitation.new
                invitation.participant_id = @user.id
                invitation.event_id = @event.id
                invitation.participant_mobile_number = @user.phone_number
                invitation.save
                notification(invitation.participant_id, @event.id, "#{User.find_by_id(@event.owner_id).try(:user_name)} sended invitation for his event #{@event.event_name}")
              end
              @event.invitees_count = 0 if @event.invitees_count.blank?
              @event.invitees_count = @event.invitees_count.to_i + 1
              @event.save
            end
          end
        end
      end
    end
    if request.format == 'json'
      if @event.present?
        render :json => {:status => 'Success', :total_invites => @event.invitees_count}
      else
        render :json => {:status => 'There is no Event'}
      end
    end
  end


  def invitees_locations
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @event = Event.find_by_id(params[:event_id])

    if @user.present? && @event.present?
      @event_admin = EventAdmins.find_by_user_id_and_event_id(@user.id, @event.id)
      if @event_admin.present?
        @invitations = Invitation.find_all_by_event_id(@event.id)
      else
        @invitations = Invitation.find_all_by_event_id_and_is_location_provide(@event.id, true)
      end
      location_information = []
      if @invitations.present?
        @invitations.each do |invitation|
          @user_location = UserLocation.find_all_by_user_id(invitation.participant_id).last
          if @user_location.present? && @event.longitude.present? && @event.latitude.present? && @user_location.longitude.present? && @user_location.latitude.present?
            distance= getDistanceFromLatLonInKm(@event.latitude, @event.longitude, @user_location.latitude, @user_location.longitude)
          else
            distance = "not available"
          end
          lat = @user_location.present? && @user_location.latitude.present? ? @user_location.latitude : ""
          lan = @user_location.present? && @user_location.longitude.present? ? @user_location.longitude : " "
          time = @user_location.present? && @user_location.time.present? ? @user_location.time : " "
          location_information << LocationInformation.new(@user.user_name, @user.id, @user.phone_number, lat, lan, distance, time)
        end
      end
    end
    if request.format == 'json'
      if @user.present? && @event.present?
        render :json => {:location_information => location_information}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end
  end


  def invitees_distances
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id)
    @event = Event.find_by_id(params[:event_id])
    if @user.present? && @event.present?
      @event_admin = EventAdmins.find_by_user_id_and_event_id(@user.id, @event.id)
      if @event_admin.present?
        @invitations = Invitation.find_all_by_event_id(@event.id)
      else
        @invitations = Invitation.find_all_by_event_id_and_is_distance_provide(@event.id, true)
      end

      all_user_ids = []
      @invitations.each do |invitation|
        all_user_ids << invitation.participant_id
      end
      distance_information = []
      all_user_ids.each do |user_id|
        @user_location = UserLocation.find_all_by_user_id(user_id).last
        if @event.longitude.present?&&@event.latitude.present?&&@user_location.longitude.present?&&@user_location.latitude.present?
          distance= getDistanceFromLatLonInKm(@event.latitude, @event.longitude, @user_location.latitude, @user_location.longitude)
        else
          distance = "not available"
        end
        distance_information << DistanceInformation.new(@user.user_name, @user.phone_number, distance, @user_location.time)
      end
    end
    if request.format == 'json'
      if @user.present? && params[:event_id].present?
        render :json => {:distance_information => distance_information}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end
  end


  def get_all_events_information
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      event_information = []
      @my_events = Event.find_all_by_owner_id_and_hide(@user.id,false)
      @my_invitation_events = Invitation.where("participant_id =? and is_blocked =? and is_rejected =?" ,@user.id,false,false)
      my_invitation_event_ids = []
      @my_invitation_events.each do |my_invitation|
        event = Event.find_by_id(my_invitation.event_id)
        my_invitation_event_ids << my_invitation.event_id if !event.hide
      end
      my_event_ids= []
      @my_events.each do |event|
        my_event_ids << event.id
      end
      event_ids = my_invitation_event_ids + my_event_ids
      event_ids = event_ids.uniq

      event_information = []
      event_ids.each do |event_id|
        event = Event.find_by_id(event_id)
        img_url = (image = Images.find_by_id(event.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
        @event_admin = EventAdmins.find_by_user_id_and_event_id(@user.id, event.id)
        is_admin = @event_admin.present? ? true : false
        is_expire = event.end_date <= Time.now
        owner_info = User.find_by_id(event.owner_id)
        owner_img = (image = Images.find_by_id(owner_info.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
        owner_information = OwnerInformation.new(owner_info.id, owner_info.user_name, owner_info.phone_number, owner_info.email, owner_info.status, owner_img)
        is_my_event = event.owner_id.eql?(@user.id) ? true : false
        invitation = Invitation.find_by_event_id_and_participant_id(event_id,@user.id)
        is_accepted = is_my_event || (invitation.present? && invitation.is_accepted) ? true : false
        @invitations = Invitation.find_all_by_event_id(event.id) if is_admin
        @invitations = Invitation.find_all_by_event_id_and_is_blocked_and_is_accepted(event.id,false,true) if !is_admin
        invitation_information = []
        @invitations.each do |invitation|
          invitation_details = InvitationDetails.new
          invitation_details.is_accepted= invitation.is_accepted ? true : false
          user = User.find_by_id(invitation.participant_id)
          user = User.find_by_phone_number(invitation.participant_mobile_number) if user.blank?
          if user.present?
            invitation_details.name=user.user_name
            invitation_details.mobile=user.phone_number
            invitation_details.user_id = user.id
            user_location = UserLocation.where('user_id=?', user.id).last
            if user_location.present?
              invitation_details.distance= getDistanceFromLatLonInKm(event.latitude, event.longitude, user_location.latitude, user_location.longitude)
              invitation_details.update_at=distance_of_time_in_words(user_location.time, Time.now)
            end
            invitation_details.email = user.email.present? ? user.email : ""
            invitation_details.img_url = (image = Images.find_by_id(user.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
            @event_admin = EventAdmins.find_by_event_id_and_user_id(event.id,invitation.participant_id)
            invitation_details.is_admin = @event_admin.present? ? true : false
            invitation_details.is_blocked = invitation.is_blocked
            invitation_information<<invitation_details
          end

        end
        event_information << Event_information.new(event.id, event.event_name, event.start_date, event.end_date, event.latitude, event.longitude, event.address, event.invitees_count, event.accepted_count, event.rejected_count, event.check_in_count, event.is_manual_check_in, img_url, event.description, event.private, event.remainder, event.status, event.owner_id, event.is_recurring_event, event.recurring_type, is_admin, is_expire, event.event_theme, is_my_event,is_accepted, owner_information, invitation_information)
      end
    end

    if request.format == 'json'
      if @user.present?
        render :json => {:event_information => event_information}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action"}
      end
    end

  end

      def make_invite_as_admin_to_event
        user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
        @current_user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
        if @current_user.present?
        @user = User.find_by_id(params[:user_id]) if params[:user_id].present?
        @event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
        if @user.present? && @event.present?
          @event_admin = EventAdmins.find_by_event_id_and_user_id(@event.id, @user.id)
          if @event_admin.blank?
            event_admin = EventAdmins.new
            event_admin.user_id = @user.id
            event_admin.event_id = @event.id
            event_admin.save
          end
          notification(@user.id, @event.id, "#{@current_user.user_name} make you as an admin for the event  #{@event.event_name}")
        end
        end
        if request.format == 'json'
          if @current_user.present? && @event_admin.present?
            render :json => {:status => "all ready he is admin"}
          elsif @current_user.present? && event_admin.present?
            render :json => {:status => "successfully Make as admin "}
          else
            render :json => {:status => "please try with proper event and user"}
          end
        end
      end

  def delete_admins_form_events
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @event = Event.find_by_id(params[:event_id]) if params[:event_id].present? && @user.present?
    @event_admins = EventAdmins.find_by_event_id(@event.id) if @event.present?
    if @event_admins.present? && @event.present?
      @event_admin = EventAdmins.find_by_event_id_and_user_id(params[:event_id], @user.id)
      @event_admin.destroy if @event_admin.present?
      @invitation = Invitation.find_by_event_id_and_participant_id(params[:event_id], @user.id)
      @invitation.update_attribute(:is_blocked, true)
      @event_admins = EventAdmins.find_by_event_id(@event.id) if @event.present?
      @event.update_attribute(:hide, true) if @event_admins.blank?
      notification(@event.owner_id, @event.id, "#{@user.user_name} is left from the admin role")
    end
    if request.format == 'json'
      if @user.present? && @event.present?
        render :json => {:status => "successfully removed from this events",:is_success => true}
      elsif @user.present?
        render :json => {:status => "please try with proper event and user", :is_success => false}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action",:is_success => false}
      end
    end
  end


  def block_invitations
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
    if @user.present? && @event.present?
      @event_admin = EventAdmins.find_by_event_id_and_user_id(@event.id, @user.id)
      if @event_admin.present?
        @invitation = Invitation.find_by_event_id_and_participant_id(@event.id,params[:user_id]) if params[:user_id].present?
        @invitation.update_attribute(:is_blocked,true) if @invitation.present?
      end
    end

    if request.format == 'json'
      if @user.present? && @event.present? && @event_admin.present?
        render :json => {:status => "successfully blocked",:is_success => true}
      elsif @user.present?
        render :json => {:status => "please try with proper event and user",:is_success => false}
      else
        render :json => {:status => "Invalid Authentication you are not allow to do this action",:is_success => false}
      end
    end
  end

  def check_contacts
    my_contacts = params[:my_contacts]
    contacts_details =[]
    if my_contacts.present?
      my_contacts.each do |my_contact|
        @user = User.find_by_phone_number_and_is_app_login(my_contact['mobile_number'],true)
        is_active_user = @user.present? ? true : false
        user_email = @user.present? && @user.email.present? ? @user.email : ""
        img_url = " "
        if @user.present? && @user.image_id.present?
        img_url = (image = Images.find_by_id(@user.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          end
        contacts_details << ContactsDetails.new(my_contact['user_name'], my_contact['mobile_number'], is_active_user,user_email, img_url)
      end
    end
    respond_to do |format|
      if params[:my_contacts].present?
        format.json { render :json => {:contacts_details => contacts_details} }
      else
        format.json { render :json => {:error_message => "please check once something is not a valid."} }
      end
    end
  end


  def differentiate_invitees
    @event = Event.find_by_id(params[:event_id])
    event_all_invitees=[]
    if @event.present?

      below_10_min_invitees_details = EventInviteesDetails.new
      below_10_min_invitees_details.title='With in 10 Min'
      below_10_min_invitees_details.invitees_list=[]

      below_30_min_invitees_details = EventInviteesDetails.new
      below_30_min_invitees_details.title='With in 30 Min'
      below_30_min_invitees_details.invitees_list=[]

      below_60_min_invitees_details = EventInviteesDetails.new
      below_60_min_invitees_details.title='With in 1 Hour'
      below_60_min_invitees_details.invitees_list=[]

      above_60_min_invitees_details = EventInviteesDetails.new
      above_60_min_invitees_details.title='Above 1 Hour'
      above_60_min_invitees_details.invitees_list=[]


      invitations = Invitation.where("event_id =? and is_accepted=? and is_blocked=? and is_rejected=?", @event.id, true, false, false)
      invitations.each do |invitation|
        user = User.find_by_id(invitation.participant_id)
        if user.present?
          user_name = user.user_name.present? ? user.user_name : ''
          mobile_number = user.phone_number.present? ? user.phone_number : ''
          email = user.email.present? ? user.email : ''
          img_url = (image = Images.find_by_id(user.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
          user_location = UserLocation.where('user_id=?', invitation.participant_id).last
          distance =""
          update_at=""
          reaching_time = 0
          if user_location.present?
            distance= getDistanceFromLatLonInKm(@event.latitude, @event.longitude, user_location.latitude, user_location.longitude)
            update_at=distance_of_time_in_words(user_location.time, Time.now)
            response =HTTParty.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=#{@event.latitude},#{@event.longitude}&destinations=#{user_location.latitude},#{user_location.longitude}&sensor=false")
            rows = response['rows'] if response.present?
            if rows.present?
              rows.each do |row|
                row['elements'].each do |element|
                  reaching_time = element['duration']['value'] if element['duration']['value'].present?
                end
              end
            end
          end
          @event_admin = EventAdmins.find_by_event_id_and_user_id(@event.id, invitation.participant_id)
          is_admin = @event_admin.present? ? true : false
        end

        if (reaching_time > 3600) || reaching_time == 0
          above_60_min_invitees_details.invitees_list << EventInvitations.new(user_name, mobile_number, email, invitation.participant_id, img_url, distance, update_at, is_admin)
        elsif reaching_time < 3600 && reaching_time > 1800
          below_60_min_invitees_details.invitees_list  << EventInvitations.new(user_name, mobile_number, email, invitation.participant_id, img_url, distance, update_at, is_admin)
        elsif reaching_time < 1800 && reaching_time > 600
          below_30_min_invitees_details.invitees_list << EventInvitations.new(user_name, mobile_number, email, invitation.participant_id, img_url, distance, update_at, is_admin)
        elsif  reaching_time < 600 && reaching_time > 0
          below_10_min_invitees_details.invitees_list << EventInvitations.new(user_name, mobile_number, email, invitation.participant_id, img_url, distance, update_at, is_admin)
        end
      end

      below_10_min_invitees_details.total_invitees = below_10_min_invitees_details.invitees_list.size
      below_30_min_invitees_details.total_invitees = below_30_min_invitees_details.invitees_list.size
      below_60_min_invitees_details.total_invitees = below_60_min_invitees_details.invitees_list.size
      above_60_min_invitees_details.total_invitees = above_60_min_invitees_details.invitees_list.size

      event_all_invitees << below_10_min_invitees_details
      event_all_invitees << below_30_min_invitees_details
      event_all_invitees << below_60_min_invitees_details
      event_all_invitees << above_60_min_invitees_details
    end


    respond_to do |format|
      format.json { render :json => {:all_invitees_list => event_all_invitees} }
    end
  end

end
