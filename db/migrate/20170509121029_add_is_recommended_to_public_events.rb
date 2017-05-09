class AddIsRecommendedToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :is_recommended, :boolean,default: false
  end
end
