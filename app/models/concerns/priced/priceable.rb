module Priced
  module Priceable
    extend ActiveSupport::Concern

    include BasePrices
    include WeekendPrices
    include SeasonalPrices
    include CurrentPrices

    def price_at(
      date,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      seasonal_price_at(date, duration_unit:, duration_value:) ||
        weekend_price_at(date, duration_unit:, duration_value:) ||
        base_price(duration_unit:, duration_value:)
    end

    def prices_at(date)
      seasonal_prices_at(date).presence ||
        weekend_prices_at(date).presence ||
        base_prices.active
    end
  end
end
