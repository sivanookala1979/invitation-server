module EventsHelper

  class InvitationDetails
    attr_accessor :name, :user_id, :mobile, :is_accepted, :distance, :update_at, :email, :img_url, :is_admin, :is_blocked
  end

  class ContactsDetails
    attr_accessor :name, :mobile_number, :is_active_user, :email, :img_url
    def initialize(name, mobile_number, is_active_user, email, img_url)
      @name = name
      @mobile_number = mobile_number
      @is_active_user = is_active_user
      @email = email
      @img_url = img_url
    end
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


  class Event_information
    attr_accessor :id, :event_name, :start_date, :end_date, :latitude, :longitude, :address, :invitees_count, :accepted_count, :rejected_count, :check_in_count, :is_manual_check_in, :image_url, :description, :private, :remainder, :status, :owner_id, :is_recurring_event, :recurring_type, :is_admin, :is_expire, :event_theme,:is_my_event,:is_accepted,:owner_information,:invitation_information

    def initialize(id, event_name, start_date, end_date, latitude, longitude, address, invitees_count, accepted_count, rejected_count, check_in_count, is_manual_check_in, image_url, description, private, remainder, status, owner_id, is_recurring_event, recurring_type, is_admin, is_expire, event_theme,is_my_event,is_accepted,owner_information,invitation_information)
      @id = id
      @event_name = event_name
      @end_date = end_date
      @start_date = start_date
      @latitude = latitude
      @longitude = longitude
      @address = address
      @invitees_count = invitees_count
      @accepted_count = accepted_count
      @rejected_count = rejected_count
      @check_in_count =check_in_count
      @is_manual_check_in =is_manual_check_in
      @image_url = image_url
      @description = description
      @private = private
      @remainder =remainder
      @status = status
      @owner_id = owner_id
      @is_recurring_event =is_recurring_event
      @recurring_type =recurring_type
      @is_admin = is_admin
      @is_expire = is_expire
      @event_theme = event_theme
      @is_my_event = is_my_event
      @is_accepted = is_accepted
      @owner_information = owner_information
      @invitation_information = invitation_information
    end
  end

  class OwnerInformation
    attr_accessor :id, :user_name, :phone_number, :email, :status, :owner_img

    def initialize(id, user_name, phone_number, email, status, owner_img)
      @id = id
      @user_name = user_name
      @phone_number = phone_number
      @email = email
      @status = status
      @owner_img = owner_img

    end
  end


  class EventInvitations
    attr_accessor :name, :mobile, :email, :user_id, :img_url, :distance, :update_at, :is_admin
    def initialize(name, mobile, email, user_id, img_url, distance, update_at, is_admin)
      @name = name
      @mobile = mobile
      @email = email
      @user_id = user_id
      @img_url = img_url
      @distance = distance
      @update_at = update_at
      @is_admin =is_admin
    end
  end

end
