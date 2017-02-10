class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :title
      t.string :description
      t.boolean :active
      t.string :currency_symbol
      t.string :country_code
      t.integer :mobile_number_count
      t.string :sys_country_code
      t.string :country_name
      t.text :remarks

      t.timestamps
    end
  end
end
