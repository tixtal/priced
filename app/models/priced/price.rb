module Priced
  class Price < ApplicationRecord
    belongs_to :priceable, polymorphic: true

    enum :price_type, {
      base: "base",
      seasonal: "seasonal",
      weekend: "weekend"
    }, suffix: :price

    monetize :price_cents, numericality: { greater_than_or_equal_to: 0 }

    validates :price_type, presence: true
    validates :price_type,
              uniqueness: { scope: %i[priceable_id priceable_type] },
              if: -> { price_type == "base" }
    validates :start_date, :end_date, presence: true, if: -> { seasonal_price? }
  end
end
