module GroupsHelper
  class GroupInformation
    attr_accessor :group_name, :create_person_name, :create_person_id, :created_at, :group_members

    def initialize(group_name, create_person_name, create_person_id, created_at, group_members)
      @group_name = group_name
      @create_person_name = create_person_name
      @create_person_id = create_person_id
      @created_at = created_at
      @group_members = group_members
    end
  end
end
