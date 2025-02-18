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

    def price_at(
      date:,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      seasonal_price_at(date:, duration_unit:, duration_value:) ||
        weekend_price_at(date:, duration_unit:, duration_value:) ||
        base_price(duration_unit:, duration_value:)
    end

    def current_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      price_at(date: Time.zone.today, duration_unit:, duration_value:)
    end

    def base_price(
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      base_prices.where(duration_unit:, duration_value:).first
    end

    def weekend_price_at(
      date:,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      return unless Priced.weekend_days.include?(date.wday)

      weekend_prices.where(duration_unit:, duration_value:).first
    end

    def seasonal_price_at(
      date:,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      seasonal_prices.where(duration_unit:, duration_value:)
                     .where(
                        seasonal_price_at_sql,
                        date:,
                        month: date.month,
                        day: date.day,
                        wday: date.wday,
                     ).order(start_date: :desc).first
    end

    private

    def seasonal_price_at_sql
      <<-SQL.squish
        CASE
          WHEN recurring_start_month IS NOT NULL
            THEN (
              (:month BETWEEN recurring_start_month AND recurring_end_month) AND
              (
                CASE
                  WHEN recurring_start_wday IS NOT NULL
                    THEN (:wday BETWEEN recurring_start_wday AND recurring_end_wday)
                  ELSE
                    (:day BETWEEN recurring_start_day AND recurring_end_day)
                END
             )
            )
          ELSE
            start_date <= :date AND end_date >= :date
        END
      SQL
    end
  end
end
