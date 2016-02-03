class AddIsCheckInToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :is_check_in, :boolean, :default=>false
  end
end
