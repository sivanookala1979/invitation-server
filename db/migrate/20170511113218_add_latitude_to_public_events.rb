class AddLatitudeToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :latitude, :decimal,default: 0.0
    add_column :public_events, :longitude, :decimal,default: 0.0
  end
end
