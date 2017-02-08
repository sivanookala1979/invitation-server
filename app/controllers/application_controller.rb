class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  def current_user_session
    @current_user_session = UserSession.find
  end


  def current_user
    if current_user_session.blank? || current_user_session.record.blank?
      access_token_key = request.headers['Authorization']
      if  !access_token_key.blank?
        access_token = UserAccessToken.find_by_access_token(access_token_key)
        if !access_token.blank?
          current_user_record = User.find_by_id(access_token.user_id)
          @user_session = UserSession.create(current_user_record, false)
          @user_session.save
        end
      end
    end

    @current_user = current_user_session && current_user_session.record
  end

end
