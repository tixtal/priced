module Priced
  module Priceable::BasePrices
    extend ActiveSupport::Concern

    included do
      has_many :base_prices,
              -> { base_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(_, price) { price.price_type = :base }

      accepts_nested_attributes_for :base_prices, allow_destroy: true
    end

    def base_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      base_prices.active.where(duration_unit:, duration_value:).first
    end
  end
end
