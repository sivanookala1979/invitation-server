module GroupsHelper
  class GroupInformation
    attr_accessor :group_id, :group_name, :create_person_name, :create_person_id, :created_at, :group_members

    def initialize(group_id, group_name, create_person_name, create_person_id, created_at, group_members)
      @group_id = group_id
      @group_name = group_name
      @create_person_name = create_person_name
      @create_person_id = create_person_id
      @created_at = created_at
      @group_members = group_members
    end
  end
  class Group_member
    attr_accessor :group_member_id, :is_group_admin, :user_id, :user_mobile_number, :user_name
    def initialize(group_member_id, is_group_admin, user_id, user_mobile_number, user_name)
      @group_member_id = group_member_id
      @is_group_admin = is_group_admin
      @user_id = user_id
      @user_mobile_number = user_mobile_number
      @user_name = user_name
    end
  end
end
