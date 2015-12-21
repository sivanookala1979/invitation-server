class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :participant_id
      t.integer :event_id
      t.boolean :is_accepted

      t.timestamps
    end
  end
end
