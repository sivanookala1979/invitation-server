module ChatRoomsHelper
  class ChatRoomViewObject
    attr_accessor :other_user_id, :other_user_name, :unread_messages_count, :image_url, :latest_msg_date_time, :latest_message, :chat_room_id, :sort_date_time,:is_group
  end

  def self_or_other(message)
    message.from_id == -999 ? "self" : "other"
  end
end
