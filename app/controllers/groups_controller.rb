class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
  include ApplicationHelper
  include GroupsHelper
  def index
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_group
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      group = Group.new
      group.group_name = params[:name]
      group.owner_id = @user.id
      group.save
      if group.present? && params[:contact_numbers].present?
        contact_numbers = params[:contact_numbers].split(',')
        contact_numbers.each do |number|
          if number.present?
            mobile_number = number.delete(' ')
            user = User.find_by_phone_number(mobile_number)
            if user.blank?
              if mobile_number.present?
                user = User.new
                user.user_name = mobile_number
                user.phone_number = mobile_number
                user.save
              end
              user_access_token = UserAccessTokens.find_by_user_id(user.id)
              if user_access_token.blank?
                user_access_token = UserAccessTokens.new
                user_access_token.user_id = user.id
                user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
                user_access_token.save
              end
            end
            group_member = GroupMembers.new
            group_member.group_id = group.id
            group_member.user_id = user.id
            group_member.user_name = user.user_name
            group_member.user_mobile_number = user.phone_number
            group_member.is_group_admin = false
            group_member.save
          end
        end
      end
      admin_group_member = GroupMembers.find_by_user_id_and_group_id(@user.id, group.id) if group.present?
      if admin_group_member.blank?
        group_member = GroupMembers.new
        group_member.group_id = group.id
        group_member.user_id = @user.id
        group_member.user_name = @user.user_name
        group_member.user_mobile_number = @user.phone_number
        group_member.is_group_admin = true
        group_member.save
      end
    end
    respond_to do |format|
      if @user.present? && group.present?
        format.json { render :json => {:group_id => group.id, :status => 'Group successfully created'} }
      else
        format.json { render :json => {:error_message => 'Invalid Authentication you are not allow to do this action'} }
      end
    end
  end

  def get_my_groups
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      group_ids = []
      group_members = GroupMembers.find_all_by_user_id(@user.id)
      group_members.each do |group_member|
        group_ids << group_member.group_id
      end
      group_information = []
      group_ids.each do |group_id|
        @group = Group.find_by_id(group_id)
        #@group_members = GroupMembers.find_all_by_group_id(group_id)
          user = User.find_by_id(@group.owner_id) if @group.present?
          group_information << GroupInformation.new(@group.id, @group.group_name, user.user_name, @group.owner_id, user.phone_number, @group.created_at) if user.present?
      end
    end
    if request.format == 'json'
      if @user.present?
        render :json => {:groups => group_information}
      else
        render :json => {:error_message => 'Invalid login details'}
      end
    end
  end

  def get_group_members
    @group = Group.find_by_id(params[:group_id]) if params[:group_id].present?
    @group_members = GroupMembers.find_all_by_group_id(@group.id) if @group.present?
    group_members =[]
    if @group_members.present?
      @group_members.each do |member|
        user = User.find_by_id(member.user_id)
        img_url = (image = Images.find_by_id(user.image_id)).present? ? ApplicationHelper.get_root_url+image.image_path.url(:original) : ''
        group_members << Group_member.new(member.id, member.is_group_admin, member.user_id, user.phone_number, user.user_name,user.email,img_url)
      end
    end
    if request.format == 'json'
      if @group.present?
        render :json => {:group_members => group_members}
      else
        render :json => {:error_message => 'there is no group with this id'}
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :ok }
    end
  end

  def differentiate_contacts
    mobile_numbers= params[:mobile_numbers].split(',')
    invitation_app_contacts =[]
    sms_contacts = []
    mobile_numbers.each do |mobile_number|
      puts mobile_number
      user = User.find_by_phone_number(mobile_number)
      if user.present? && user.is_app_login.eql?(true)
        invitation_app_contacts << mobile_number
      else
        sms_contacts << mobile_number
      end
    end
    if request.format == 'json'
      render :json => {:invitation_app_contacts => invitation_app_contacts, :sms_contacts => sms_contacts}
    end

  end

  def create_group_by_invites
    event = Event.find_by_id(params[:event_id])
    if event.present?
      group = Group.new
      group.owner_id=event.owner_id
      group.group_name = params[:name]
      group.contact_numbers=" "
      group.save
      invitations = Invitation.find_all_by_event_id(event.id)
      if group.present? && invitations.present?
        invitations.each do |invitation|
          user = User.find_by_id(invitation.participant_id)
          group_member = GroupMembers.new
          group_member.group_id = group.id
          group_member.user_id = user.id
          group_member.user_name = user.user_name
          group_member.user_mobile_number = user.phone_number
          group_member.is_group_admin = false
          group_member.save
        end
      end
      admin_group_member = GroupMembers.find_by_user_id_and_group_id(event.owner_id, group.id)
      if admin_group_member.blank?
        @user = User.find_by_id(event.owner_id)
        group_member = GroupMembers.new
        group_member.group_id = group.id
        group_member.user_id = @user.id
        group_member.user_name = @user.user_name
        group_member.user_mobile_number = @user.phone_number
        group_member.is_group_admin = true
        group_member.save
      end
    end
    respond_to do |format|
      if event.present? && group.present?
        format.json { render :json => {:group_id => group.id, :status => 'Group successfully created'} }
      else
        format.json { render :json => {:error_message => 'There is no Event'} }
      end
    end
  end

  def group_members_list
    @group_members = GroupMembers.find_all_by_group_id(params[:group_id])
  end

  def event_admins
    @event_admins = EventAdmins.all.reverse
  end


end
