class ChatRoomsController < ApplicationController
  # GET /chat_rooms
  # GET /chat_rooms.json
  include ApplicationHelper
  include ChatRoomsHelper
  def index
    @chat_rooms = ChatRoom.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chat_rooms }
    end
  end

  # GET /chat_rooms/1
  # GET /chat_rooms/1.json
  def show
    @chat_room = ChatRoom.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @chat_room }
    end
  end

  # GET /chat_rooms/new
  # GET /chat_rooms/new.json
  def new
    @chat_room = ChatRoom.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @chat_room }
    end
  end

  # GET /chat_rooms/1/edit
  def edit
    @chat_room = ChatRoom.find(params[:id])
  end

  # POST /chat_rooms
  # POST /chat_rooms.json
  def create
    @chat_room = ChatRoom.new(params[:chat_room])

    respond_to do |format|
      if @chat_room.save
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully created.' }
        format.json { render json: @chat_room, status: :created, location: @chat_room }
      else
        format.html { render action: "new" }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /chat_rooms/1
  # PUT /chat_rooms/1.json
  def update
    @chat_room = ChatRoom.find(params[:id])

    respond_to do |format|
      if @chat_room.update_attributes(params[:chat_room])
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chat_rooms/1
  # DELETE /chat_rooms/1.json
  def destroy
    @chat_room = ChatRoom.find(params[:id])
    @chat_room.destroy

    respond_to do |format|
      format.html { redirect_to chat_rooms_url }
      format.json { head :ok }
    end
  end

#inter chat with group
  def get_inter_chat_messages
    is_group= false
    is_group = params[:is_group] if params[:is_group].present?
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if is_group
      @messages = ChatMessage.where("event_id =?" ,params[:other_id] ).order('created_at DESC')
    else
      ensure_inter_chat_room(@user.id, params[:other_id], is_group)
      @messages = ChatMessage.where("chat_room_id =?" ,@inter_chat.id ).order('created_at DESC')
    end
      @inter_messages = []
       @messages.each do |message|
        user = User.find_by_id(message.from_id)
        @inter_messages << ChatSms.new(message.chat_room_id,message.from_id,user.user_name,message.message,message.created_at,get_time_format_app(message.updated_at))
       end
    respond_to do |format|
      format.json { render json: @inter_messages }
    end
  end

  def post_inter_chat_message
      is_group= false
      is_group = params[:is_group]  if params[:is_group].present?

    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    ensure_inter_chat_room(@user.id, params[:other_id], is_group) if !is_group
    @message = ChatMessage.new
    @message.from_id = @user.id
    @message.chat_room_id = @inter_chat.id if !is_group
    @message.message = params[:message]
    @message.event_id = params[:other_id] if is_group
    @message.save!
      status = @message.present? ? true : false

      if is_group
        @event = Event.find_by_id(params[:other_id])
        if @event.present?
          @invitations = Invitation.where("event_id =? and is_accepted =? and participant_id=?", params[:other_id], true,!@user.id)
          @invitations.each do |invitation|
            @other_user = User.find_by_id(invitation.participant_id) if invitation.participant_id.present?
            post_gcm_message(@message.message, invitation.participant_id, @user.id, @user.user_name, '', "Chat", true, @event.event_name, @event.id) if @other_user.present? && @other_user.is_app_login.eql?(true)
          end
        else
          status=false
        end
      else
        post_gcm_message(@message.message, params[:other_id], @user.id, @user.user_name, '', "Chat", false, "", "")
      end
    respond_to do |format|
      format.json { render :json => {:status => status} }
    end
  end

  def ensure_inter_chat_room(user_id1, user_id2, is_group)
    @inter_chat = ChatRoom.find_by_user_id_and_other_id_and_is_group(user_id1, user_id2, is_group)
    @inter_chat ||= ChatRoom.find_by_user_id_and_other_id_and_is_group(user_id2, user_id1, is_group)
    if @inter_chat.nil?
      @inter_chat = ChatRoom.new
      @inter_chat.user_id = user_id1
      @inter_chat.other_id = user_id2
      @inter_chat.is_group = true if is_group
      @inter_chat.save!
    end
  end
  #end of inter chat with group

  def get_chats
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @chat_rooms = ChatRoom.where('(user_id = ? or other_id = ?) and is_group = ?', @user.id, @user.id, false).order('updated_at DESC')
    @group_chat_rooms = ChatRoom.where('(user_id = ? or other_id = ?) and is_group = ?', @user.id, @user.id, true).order('updated_at DESC')
    @chat_room_view_objects_individual = @chat_rooms.collect { |chat_room|
      chat_room_view_object = ChatRoomsHelper::ChatRoomViewObject.new
      puts chat_room.get_other_party_id(@user.id)
      chat_room_view_object.other_user_id = chat_room.get_other_party_id(@user.id)
      user = User.find_by_id(chat_room_view_object.other_user_id)
      chat_room_view_object.other_user_name = user.present? && user.user_name.present? ? user.user_name : ''
      chat_room_view_object.chat_room_id = chat_room.id
      chat_room_view_object.unread_messages_count = 0
      chat_room_view_object.sort_date_time = Time.now - 2.year
      chat_room_view_object.is_group = false
      if user.present?
        picture = Images.find_by_id(user.image_id)
        chat_room_view_object.image_url = picture.present? ? root_url+"#{picture.image_path.url(:small)}" : ''
        chat_messages = ChatMessage.where('chat_room_id =?', chat_room.id).order('updated_at DESC')
        if chat_messages.present? && chat_messages.size > 0
          chat_room_view_object.latest_msg_date_time = get_time_format(chat_messages[0].updated_at)
          chat_room_view_object.sort_date_time = chat_messages[0].updated_at
          chat_room_view_object.latest_message = chat_messages[0].message
        end
      end
      chat_room_view_object
    }

    @chat_room_view_objects_group = @group_chat_rooms.collect { |chat_room|
      chat_room_view_object = ChatRoomsHelper::ChatRoomViewObject.new
      chat_room_view_object.other_user_id = chat_room.get_other_party_id(@user.id)
      group = Group.find_by_id(chat_room_view_object.other_user_id)
      chat_room_view_object.other_user_name = group.present? && group.name.present? ? group.name : ''
      chat_room_view_object.chat_room_id = chat_room.id
      chat_room_view_object.is_group = true
      if group.present?
        picture = Images.find_by_id(user.image_id)
        chat_room_view_object.image_url = picture.present? ? root_url+"#{picture.image_path.url(:small)}" : ''
        chat_messages = ChatMessage.where('chat_room_id =?', chat_room.id).order('updated_at DESC')
        if chat_messages.present? && chat_messages.size > 0
          chat_room_view_object.latest_msg_date_time = get_time_format_app(chat_messages[0].updated_at)
          chat_room_view_object.sort_date_time = chat_messages[0].updated_at
          chat_room_view_object.latest_message = chat_messages[0].message
        end
      end
      chat_room_view_object
    }
    @chat_room_view_objects = []
    if @chat_room_view_objects_individual.present? && @chat_room_view_objects_group.present?
      @chat_room_view_objects = @chat_room_view_objects_individual+@chat_room_view_objects_group
    elsif @chat_room_view_objects_individual.present?
      @chat_room_view_objects = @chat_room_view_objects_individual
    elsif @chat_room_view_objects_group.present?
      @chat_room_view_objects = @chat_room_view_objects_group
    end
    if @chat_room_view_objects.present?
      @chat_room_view_objects.sort! { |a, b|  b.sort_date_time <=> a.sort_date_time }
    end
    respond_to do |format|
      format.json { render json: @chat_room_view_objects }
    end
  end

  def ensure_chat_room(user_id, other_id, is_group)
    @support_chat = ChatRoom.find_by_user_id_and_other_id(user_id, other_id)
    if @support_chat.nil?
      @support_chat = ChatRoom.new
      @support_chat.user_id = user_id
      @support_chat.other_id = other_id
      @support_chat.is_group=true if is_group
      @support_chat.save!
    end
  end

  def post_gcm_message(content, to_user_id, from_user_id,user_name, image_url, notification_type,is_group,event_name,event_id)
    user = User.find_by_id(to_user_id)
    @error_message = nil
    if user.present? && user.gcm_code.present?
      gcm = GCM.new('AIzaSyBfBtl4go_-zhG-6o122tN03ob15w_cvOY')
      registration_ids= [user.gcm_code]
      response = nil
        options = {data: {message: content, title: notification_type,from_user_id: from_user_id,from_user_name:user_name, is_group: is_group,event_name:event_name,event_id:event_id}, collapse_key: 'updated_score'}
        response = gcm.send(registration_ids, options)
        gcm_results = JSON.parse(response[:body])['results'][0]
        @error_message = gcm_results['error']
      @error_message ||= 'Successfully posted.'
    end
  end
end
