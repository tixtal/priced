module Priced
  module Priceable
    extend ActiveSupport::Concern

    included do
      has_many :seasonal_prices,
               -> { seasonal_price },
               as: :priceable,
               class_name: "Priced::Price",
               dependent: :destroy,
               before_add: ->(price) { price.price_type = :seasonal }
      has_many :weekend_prices,
              -> { weekend_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(price) { price.price_type = :weekend }
      has_one :base_price,
              -> { base_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy
    end

    def current_price
      current_seasonal_price || current_weekend_price || base_price
    end

    private

    def current_seasonal_price
      seasonal_prices.where(
        "start_date >= :today AND end_date <= :today",
        today: Time.zone.today
      ).order(start_date: :desc).first
    end

    def current_weekend_price
      return unless Priced.weekend_days.include?(Time.zone.today.wday)

      weekend_prices.where(price_type: :weekend).where(
        "(start_date IS NULL OR (start_date >= :today AND end_date <= :today))",
        today: Time.zone.today
      ).order(start_date: :desc).first
    end
  end
end
