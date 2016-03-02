class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
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
    group = Group.new
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if !user_access_token.blank?
    user = User.find_by_id(user_access_token.user_id)
    group.owner_id = user.id
    group.group_name = params[:name]
    group.contact_numbers = params[:contact_numbers]
    group.save
    if request.format == 'json'
      render :json => {:id =>  group.id ,:status =>'Group successfully created'}
    end
    else
      render :json => {:status =>'Invalid login details'}
      end
  end

   def get_my_groups
     user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
     if user_access_token.present?
       user = User.find_by_id(user_access_token.user_id)
      all_groups = Group.find_all_by_owner_id(user.id)
     if request.format == 'json'
         render :json => {:groups => all_groups}
       else
         render :json => {:status => "Invalid Authentication you are not allow to do this action"}
       end
     end
   end

  # PUT /groups/1
  # PUT /groups/1.json
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
      if user.present?
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
    invitations = Invitation.find_all_by_event_id(event.id)
    mobile_numbers = ''
    invitations.each do |invitation|
      mobile_numbers+=invitation.participant_mobile_number+","
    end
    group = Group.new
    group.owner_id=event.owner_id
    group.group_name = params[:name]
    group.contact_numbers=mobile_numbers[0, mobile_numbers.length-1]
    group.save

    if request.format == 'json'
      render :json => {:status => "Group Was successfully created with the name #{params[:name]}"}
    end
  end
end
