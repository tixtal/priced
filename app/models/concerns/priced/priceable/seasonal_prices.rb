module Priced
  module Priceable::SeasonalPrices
    extend ActiveSupport::Concern

    included do
      has_many :seasonal_prices,
               -> { seasonal_price },
               as: :priceable,
               class_name: "Priced::Price",
               dependent: :destroy,
               before_add: ->(_, price) { price.price_type = :seasonal }

      accepts_nested_attributes_for :seasonal_prices, allow_destroy: true
    end

    def seasonal_price_at(
      date,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      seasonal_prices_at(date).where(duration_unit:, duration_value:).first
    end

    def seasonal_prices_at(date)
      seasonal_prices.active.where(Query.seasonal_price_at(date)).order(start_date: :desc)
    end
  end
end
