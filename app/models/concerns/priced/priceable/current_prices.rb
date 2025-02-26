module Priced
  module Priceable::CurrentPrices
    extend ActiveSupport::Concern

    def current_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      price_at(Time.zone.today, duration_unit:, duration_value:)
    end

    def current_prices
      prices_at(Time.zone.today)
    end
  end
end
