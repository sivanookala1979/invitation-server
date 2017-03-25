module ChatRoomsHelper
  class ChatRoomViewObject
    attr_accessor :other_user_id, :other_user_name, :unread_messages_count, :image_url, :latest_msg_date_time, :latest_message, :chat_room_id, :sort_date_time, :is_group
  end

  class ChatSms
    attr_accessor :chat_room_id, :from_id, :user_name, :message, :created_at, :updated_at,:image

    def initialize(chat_room_id, from_id, user_name, message, created_at, updated_at,image)
      @chat_room_id = chat_room_id
      @from_id = from_id
      @user_name = user_name
      @message= message
      @created_at = created_at
      @updated_at = updated_at
      @image = image
    end
  end


  def self_or_other(message)
    message.from_id == -999 ? "self" : "other"
  end
end
