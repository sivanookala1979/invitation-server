class AddIsBlockedToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :is_blocked, :boolean, :default=>false
  end
end
