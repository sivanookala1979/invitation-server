module EventsHelper

  class InvitationDetails
    attr_accessor :name,:user_id, :mobile, :is_accepted, :distance, :update_at,:email,:img_url
  end

  class EventDetails
    attr_accessor :id, :event_name, :end_date, :description, :latitude, :longitude, :address, :private, :remainder, :status, :owner_id, :start_date, :invitees_count, :accepted_count, :rejected_count, :is_manual_check_in, :check_in_count, :is_recurring_event, :recurring_type, :event_theme, :is_accepted, :is_admin,:is_expire

    def initialize(id, event_name, end_date, description, latitude, longitude, address, private, remainder, status, owner_id, start_date, invitees_count, accepted_count, rejected_count, is_manual_check_in, check_in_count, is_recurring_event, recurring_type, event_theme, is_accepted, is_admin,image_url,is_expire)
      @id = id
      @event_name = event_name
      @end_date = end_date
      @description = description
      @latitude = latitude
      @longitude = longitude
      @address =address
      @private = private
      @remainder =remainder
      @status = status
      @owner_id = owner_id
      @start_date = start_date
      @invitees_count = invitees_count
      @accepted_count = accepted_count
      @rejected_count = rejected_count
      @is_manual_check_in =is_manual_check_in
      @check_in_count =check_in_count
      @is_recurring_event =is_recurring_event
      @recurring_type =recurring_type
      @event_theme = event_theme
      @is_accepted = is_accepted
      @is_admin = is_admin
      @image_url = image_url
      @is_expire = is_expire
    end
  end


  class LocationInformation
    attr_accessor :user_name,:user_id, :mobile_number, :latitude, :longitude, :distance, :time

    def initialize(user_name,user_id, mobile_number, latitude, longitude, distance, time)
      @user_name = user_name
      @user_id = user_id
      @mobile_number = mobile_number
      @latitude = latitude
      @longitude = longitude
      @distance = distance
      @time = time
    end
  end

  class DistanceInformation
    attr_accessor :user_name, :mobile_number, :distance, :time

    def initialize(user_name, mobile_number, distance, time)
      @user_name = user_name
      @mobile_number = mobile_number
      @distance = distance
      @time = time
    end
  end

end
