class AddIsLocationProvideToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :is_location_provide, :boolean, :default => false
    add_column :invitations, :is_distance_provide, :boolean, :default => false
    add_column :invitations, :is_not_share, :boolean, :default => false
  end
end
