class AddOfferAmountToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :offer_amount, :decimal,:default => 0.0
  end
end
