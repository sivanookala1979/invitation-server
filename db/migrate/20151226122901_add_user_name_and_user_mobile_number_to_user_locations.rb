class AddUserNameAndUserMobileNumberToUserLocations < ActiveRecord::Migration
  def change
    add_column :user_locations, :user_name, :string
    add_column :user_locations, :user_mobile_number, :string
  end
end
