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
      seasonal_prices.active
                     .where(
                        seasonal_price_at_sql,
                        date:,
                        month: date.month,
                        day: date.day,
                        wday: date.wday,
                     ).order(start_date: :desc)
    end

    private

    def seasonal_price_at_sql
      <<-SQL.squish
        CASE
          WHEN recurring_start_month IS NOT NULL
            THEN (
              (:month >= recurring_start_month AND :month <= recurring_end_month) AND
              (
                CASE
                  WHEN recurring_start_wday IS NOT NULL
                    THEN (:wday >= recurring_start_wday AND :wday <= recurring_end_wday)
                  ELSE
                    (:day >= recurring_start_day AND :day <= recurring_end_day)
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
