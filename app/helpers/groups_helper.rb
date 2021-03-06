module GroupsHelper
  class GroupInformation
    attr_accessor :group_id, :group_name, :create_person_name, :create_person_id, :created_at

    def initialize(group_id, group_name, create_person_name, create_person_id,created_person_mobile, created_at)
      @group_id = group_id
      @group_name = group_name
      @create_person_name = create_person_name
      @create_person_id = create_person_id
      @created_person_mobile = created_person_mobile
      @created_at = created_at
    end
  end
  class Group_member
    attr_accessor :group_member_id, :is_group_admin, :user_id, :user_mobile_number, :user_name,:email,:img_url
    def initialize(group_member_id, is_group_admin, user_id, user_mobile_number, user_name,email,img_url)
      @group_member_id = group_member_id
      @is_group_admin = is_group_admin
      @user_id = user_id
      @user_mobile_number = user_mobile_number
      @user_name = user_name
      @email = email
      @img_url = img_url
    end
  end
end
