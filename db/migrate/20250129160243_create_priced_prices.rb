class CreatePricedPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :priced_prices do |t|
      t.references :priceable, polymorphic: true, null: false
      t.string :price_type
      t.monetize :price
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
