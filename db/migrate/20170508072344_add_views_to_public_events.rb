class AddViewsToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :views, :integer,default: 0
  end
end
