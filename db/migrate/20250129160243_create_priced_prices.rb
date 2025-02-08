class CreatePricedPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :priced_prices do |t|
      t.references :priceable, polymorphic: true, null: false
      t.string :price_type
      t.monetize :price
      t.string :duration_unit
      t.integer :duration_value
      t.date :start_date
      t.date :end_date
      t.boolean :recurring, default: false
      t.integer :recurring_start_month
      t.integer :recurring_start_day
      t.integer :recurring_start_wday
      t.integer :recurring_end_month
      t.integer :recurring_end_day
      t.integer :recurring_end_wday
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
