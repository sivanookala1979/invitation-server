class ChatRoom < ActiveRecord::Base
  has_many :chat_messages, dependent: :destroy
  def get_other_party_id(lookup_id)
    return user_id if other_id == lookup_id
    return other_id
  end
end
