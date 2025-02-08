module Priced
  module Priceable
    extend ActiveSupport::Concern

    included do
      has_many :seasonal_prices,
               -> { active.seasonal_price },
               as: :priceable,
               class_name: "Priced::Price",
               dependent: :destroy,
               before_add: ->(price) { price.price_type = :seasonal }
      has_many :weekend_prices,
              -> { active.weekend_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(price) { price.price_type = :weekend }
      has_many :base_prices,
              -> { active.base_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(price) { price.price_type = :base }

      accepts_nested_attributes_for :seasonal_prices, :weekend_prices, :base_prices
    end

    def current_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      current_seasonal_price(duration_unit:, duration_value:) ||
        current_weekend_price(duration_unit:, duration_value:) ||
        current_base_price(duration_unit:, duration_value:)
    end

    def current_base_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      base_prices.where(duration_unit:, duration_value:).first
    end

    def current_weekend_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      return if Priced.weekend_days.exclude?(Time.zone.today.wday)

      weekend_prices.where(duration_unit:, duration_value:).first
    end

    def current_seasonal_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      today = Time.zone.today

      seasonal_prices.where(duration_unit:, duration_value:)
                     .where(
                        current_seasonal_price_sql,
                        today:,
                        today_month: today.month,
                        today_day: today.day,
                        today_wday: today.wday,
                     ).order(start_date: :desc).first
    end

    private

    def current_seasonal_price_sql
      <<-SQL.squish
        CASE
          WHEN recurring_start_month IS NOT NULL
            THEN (
              (:today_month BETWEEN recurring_start_month AND recurring_end_month) AND
              (
                CASE
                  WHEN recurring_start_wday IS NOT NULL
                    THEN (:today_wday BETWEEN recurring_start_wday AND recurring_end_wday)
                  ELSE
                    (:today_day BETWEEN recurring_start_day AND recurring_end_day)
                END
             )
            )
          ELSE
            start_date <= :today AND end_date >= :today
        END
      SQL
    end
  end
end
