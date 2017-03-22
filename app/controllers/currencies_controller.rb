class CurrenciesController < ApplicationController
  # GET /currencies
  # GET /currencies.json
  def index
    @currencies = Currency.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @currencies }
    end
  end

  # GET /currencies/1
  # GET /currencies/1.json
  def show
    @currency = Currency.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @currency }
    end
  end

  # GET /currencies/new
  # GET /currencies/new.json
  def new
    @currency = Currency.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @currency }
    end
  end

  # GET /currencies/1/edit
  def edit
    @currency = Currency.find(params[:id])
  end

  # POST /currencies
  # POST /currencies.json
  def create
    @currency = Currency.new(params[:currency])

    respond_to do |format|
      if @currency.save
        format.html { redirect_to @currency, notice: 'Currency was successfully created.' }
        format.json { render json: @currency, status: :created, location: @currency }
      else
        format.html { render action: "new" }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /currencies/1
  # PUT /currencies/1.json
  def update
    @currency = Currency.find(params[:id])

    respond_to do |format|
      if @currency.update_attributes(params[:currency])
        format.html { redirect_to @currency, notice: 'Currency was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /currencies/1
  # DELETE /currencies/1.json
  def destroy
    @currency = Currency.find(params[:id])
    @currency.destroy

    respond_to do |format|
      format.html { redirect_to currencies_url }
      format.json { head :ok }
    end
  end

  def my_notifications
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if !user_access_token.present?
    if @user.present?
      @notifications = Notification.where("user_id =?", @user.id).order('created_at DESC')
      count = notifications = Notification.where('user_id =? and notified =?', @user.id, false)
    end
    respond_to do |format|
      if @user.present?
        format.json { render :json => {:notifications => @notifications, :pending_notifications => count.size} }
      else
        format.json { render :json => {:status => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

  def clear_notifications
    user_access_token = UserAccessTokens.find_by_access_token(request.headers['Authorization'])
    @user = User.find_by_id(user_access_token.user_id) if user_access_token.present?
    if @user.present?
      @notifications = Notification.find_all_by_user_id(@user.id)
      @notifications.each do |notification|
        notification.destroy
      end
    end
    respond_to do |format|
      if @user.present?
        format.json { render :json => {:status => "clear all"} }
      else
        format.json { render :json => {:status => "Invalid Authentication you are not allow to do this action"} }
      end
    end
  end

end
