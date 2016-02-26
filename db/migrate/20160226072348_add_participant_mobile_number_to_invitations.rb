class AddParticipantMobileNumberToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :participant_mobile_number, :string
  end
end
