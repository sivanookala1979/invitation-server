class AddIsRejectedToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :is_rejected, :boolean, :default=>false
  end
end
