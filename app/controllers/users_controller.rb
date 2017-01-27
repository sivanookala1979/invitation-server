class UsersController < ApplicationController

  # GET /users
  # GET /users.json
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

  def create_user
    user = User.find_by_phone_number(params[:phone_number])
    status=''
    if !user.blank?
      status="User already existed"
      user.update_attribute("is_app_login",true)
    else
      user=User.new
      user.user_name = params[:user_name]
      user.phone_number = params[:phone_number]
      users.is_app_login = true
      status="Success"
      user.save
      user_access_token = UserAccessTokens.find_by_user_id(user.id)
      if user_access_token.blank?
        user_access_token = UserAccessTokens.new
        user_access_token.user_id = user.id
        user_access_token.access_token = UUIDTools::UUID.random_create.to_s.delete '-' + 'user_access_token'
        user_access_token.save
      end
    end
    if request.format == 'json'
      if status.eql?('Success')
        render :json => {:id => user.id, :status => status, :access_token => user_access_token.access_token}
      else
        render :json => {:status => status}
      end
    end
  end

  def login
    status=''
    user = User.find_by_phone_number(params[:phone_number])
    if request.format == 'json'
      if !user.blank?
        user_access_token = UserAccessTokens.find_by_user_id(user.id)
      render :json => {:id => user.id, :access_token => user_access_token.access_token}

    else
      render :json => { :status=> "User not exist with this mobile number"}
      end
    end
    end


  # PUT /users/1
  # PUT /users/1.json
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

end
