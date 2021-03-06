class UsersController < ApplicationController

  # GET /users
  # GET /users.json
  include ApplicationHelper
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def log_in_with_mobile
    mobile_number = params[:mobile_number].delete(' ')
    @mobile_number_details = MobileLoginDetails.find_by_mobile_number(mobile_number)
    if @mobile_number_details.present?
      @mobile_number_details.update_attribute(:otp, ApplicationHelper.get_otp)
      ##send_sms(@mobile_number_details.mobile_number, "Dear Customer, your NETSECURE code is #{@mobile_number_details.otp} .")
    else
      @mobile_number_details = MobileLoginDetails.new
      @mobile_number_details.mobile_number = mobile_number
      @mobile_number_details.otp=ApplicationHelper.get_otp
      @mobile_number_details.is_valid=true
      @mobile_number_details.save
      ## send_sms(@mobile_number_details.mobile_number, "Dear Customer, your NETSECURE code is #{@mobile_number_details.otp} .")
    end
    respond_to do |format|
      format.json { render :json => {:status => 'Success'} }
    end
  end

  def register_with_mobile
    mobile_number = params[:mobile_number].delete(' ') if params[:mobile_number].present?
    @mobile_number_details = MobileLoginDetails.where('mobile_number =? and is_valid =?', mobile_number, true) if mobile_number.present?
    ##if @mobile_number_details.present? && @mobile_number_details.otp.eql?(params[:otp])
    if (true)
      user = User.find_by_phone_number(mobile_number) if mobile_number.present?
      user.update_attribute(:user_name, params[:user_name]) if user.present?
      user.update_attribute(:is_app_login, true) if user.present?
      if user.blank? && mobile_number.present?
        user = User.new
        user.phone_number = mobile_number
        user.user_name = params[:user_name] if params[:user_name].present?
        user.is_app_login = true
        user.save
      end
      if user.present?
        user_access_token = UserAccessTokens.find_by_user_id(user.id)
        if user_access_token.blank?
          user_access_token = UserAccessTokens.new
          user_access_token.user_id = user.id
          user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-'
          user_access_token.save
        end
      end
    end
    respond_to do |format|
      if user.present?
        format.json { render :json => {:user_id => user.id, :access_token => user_access_token.access_token, :is_profile_given => user.is_profile_given} }
      else
        format.json { render :json => {:status => "User not exist with this mobile number"} }
      end

    end
  end

  def get_user_details
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if user_access_token.present?
      @user = User.find_by_id(user_access_token.user_id)
      render :json => @user.as_json(:only => [:user_name, :phone_number, :is_app_login, :is_profile_given,:status,:gender,:email])
    else
      render :json => {:error_message => "Invalid Authentication you are not allow to do this action"}
    end
  end

  def update_user_details
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    if user_access_token.present?
      @user = User.find_by_id(user_access_token.user_id)
      @user.update_attribute(:user_name, params[:user_name]) if params[:user_name].present?
      @user.update_attribute(:phone_number, params[:phone_number]) if params[:phone_number].present?
      @user.update_attribute(:status, params[:status]) if params[:status].present?
      @user.update_attribute(:is_profile_given, true)
      @user.update_attribute(:gender, params[:gender])
      @user.update_attribute(:email, params[:email])
      if params[:image].present?
        image = save_image(params[:image])
        @user.update_attribute(:image_id, image.id) if image.present?
      end
    end
    if user_access_token.present?
      render :json => @user.as_json(:only => [:user_name, :phone_number, :is_app_login, :is_profile_given, :status,:gender,:email])
    else
      render :json => {:error_message => "Invalid Authentication you are not allow to do this action"}
    end
  end


  def store_gcm_code
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      @user.update_attribute(:gcm_code, params[:gcm_code])
      render :json => {:user_id => @user.id}
    else
      render :json => {:error_message => 'Invalid User.'}
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def all_user_locations
    @user_locations = UserLocation.where("user_id=?", params[:user_id]).order('created_at DESC')
  end

  def get_my_settings
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    @user_setting = UserSetting.find_by_user_id(@user.id) if @user.present?
    respond_to do |format|
      if @user_setting.present?
        format.json { render :json => {:user_settings => @user_setting} }
      else
        format.json { render :json => {:error_message => "please check once something is not a valid."} }
      end
    end
  end

  def update_my_settings
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      @user_setting = UserSetting.find_by_user_id(@user.id)
      @user_setting = UserSetting.new if @user_setting.blank?
      @user_setting.user_id = @user.id
      @user_setting.share_location_with_host = params[:share_location_with_host].present? ? params[:share_location_with_host] : @user_setting.share_location_with_host
      @user_setting.share_locattion_with_guest = params[:share_locattion_with_guest].present? ? params[:share_locattion_with_guest] : @user_setting.share_locattion_with_guest
      @user_setting.invitations = params[:invitations].present? ? params[:invitations] : @user_setting.invitations
      @user_setting.reminders = params[:reminders].present? ? params[:reminders] : @user_setting.reminders
      @user_setting.comments = params[:comments].present? ? params[:comments] : @user_setting.comments
      @user_setting.save
    end
    respond_to do |format|
      if @user_setting.present?
        format.json { render :json => {:user_settings => @user_setting} }
      else
        format.json { render :json => {:error_message => "please check once something is not a valid."} }
      end
    end
  end




end
