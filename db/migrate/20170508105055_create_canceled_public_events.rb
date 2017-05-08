class CreateCanceledPublicEvents < ActiveRecord::Migration
  def change
    create_table :canceled_public_events do |t|
      t.integer :authour_id
      t.integer :event_id
      t.integer :canceled_user_id

      t.timestamps
    end
  end
end
