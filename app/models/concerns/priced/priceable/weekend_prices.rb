module Priced
  module Priceable::WeekendPrices
    extend ActiveSupport::Concern

    included do
      has_many :weekend_prices,
              -> { weekend_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(_, price) { price.price_type = :weekend }

      accepts_nested_attributes_for :weekend_prices, allow_destroy: true
    end

    def weekend_price_at(
      date,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      weekend_prices_at(date).where(duration_unit:, duration_value:).first
    end

    def weekend_prices_at(date)
      return weekend_prices.none unless Date::WEEKEND_DAYS.include?(date.wday)

      weekend_prices.active
    end
  end
end
