class CreateMobileLoginDetails < ActiveRecord::Migration
  def change
    create_table :mobile_login_details do |t|
      t.string :mobile_number
      t.string :otp
      t.boolean :is_valid, :default => false

      t.timestamps
    end
  end
end
