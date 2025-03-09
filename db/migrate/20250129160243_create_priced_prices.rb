class CreatePricedPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :priced_prices do |t|
      t.references :priceable, polymorphic: true, null: false
      t.string :price_type
      t.monetize :amount
      t.string :duration_unit
      t.integer :duration_value
      t.date :start_date
      t.date :end_date
      t.boolean :recurring, default: false
      t.integer :recurring_start_month
      t.integer :recurring_start_day
      t.integer :recurring_end_month
      t.integer :recurring_end_day
      t.timestamps

      t.index :price_type, name: "index_priced_prices_on_price_type"
      t.index %i[duration_unit duration_value], name: "index_priced_prices_on_duration"
      t.index %i[start_date end_date], name: "index_priced_prices_on_dates"
      t.index %i[recurring_start_month recurring_end_month],
              name: "index_priced_prices_on_recurring_months"
      t.index %i[recurring_start_day recurring_end_day],
              name: "index_priced_prices_on_recurring_days"
    end
  end
end
