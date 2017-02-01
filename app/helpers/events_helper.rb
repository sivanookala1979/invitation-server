module EventsHelper

  class InvitationDetails
    attr_accessor :name, :mobile, :is_accepted, :distance, :update_at
  end

  class EventDetails
    attr_accessor :event_name, :end_date, :description, :latitude, :longitude,:address,:private,:remainder,:status,:owner_id,:start_date,:invitees_count,:accepted_count,:rejected_count,:is_manual_check_in,:check_in_count,:is_recurring_event,:recurring_type,:event_theme,:is_accepted
  end
end
