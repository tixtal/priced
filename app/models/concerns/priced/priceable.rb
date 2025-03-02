module Priced
  module Priceable
    extend ActiveSupport::Concern

    included do
      has_many :prices,
               -> { readonly },
               as: :priceable,
               class_name: "Priced::Price",
               dependent: :destroy

      has_many :current_prices,
               -> { current.readonly },
               as: :priceable,
               class_name: "Priced::Price",
               dependent: :destroy
      has_one :current_price,
              lambda {
                current.where(
                  duration_unit: Priced.default_duration_unit,
                  duration_value: Priced.default_duration_value
                ).readonly
              },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy

      has_many :base_prices,
              -> { base_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(_, price) { price.price_type = :base }
      has_one :base_price,
              lambda {
                base_price.where(
                  duration_unit: Priced.default_duration_unit,
                  duration_value: Priced.default_duration_value
                )
              },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy

      has_many :weekend_prices,
              -> { weekend_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(_, price) { price.price_type = :weekend }

      has_many :seasonal_prices,
              -> { seasonal_price },
              as: :priceable,
              class_name: "Priced::Price",
              dependent: :destroy,
              before_add: ->(_, price) { price.price_type = :seasonal }

      accepts_nested_attributes_for :base_prices, :seasonal_prices, :weekend_prices,
                                    allow_destroy: true
    end

    def price_at(
      date,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      prices.at(date).where(duration_unit:, duration_value:).first
    end

    def prices_at(date)
      prices.at(date)
    end

    def prices_within(start_date, end_date)
      sql = <<-SQL.squish
        #{Query.prices_within(":start_date", ":end_date")}
        AND priced_prices.priceable_id = #{id}
        AND priced_prices.priceable_type = '#{self.class.name}'
      SQL

      Priced::Price.find_by_sql([ sql, { start_date:, end_date: } ]).group_by(&:date)
    end

    def price_within(
      start_date,
      end_date,
      duration_unit: Priced.default_duration_unit,
      duration_value: Priced.default_duration_value
    )
      within_sql = <<-SQL.squish
        #{Query.prices_within(":start_date", ":end_date")}
        AND priced_prices.priceable_id = #{id}
        AND priced_prices.priceable_type = '#{self.class.name}'
        AND priced_prices.duration_unit = :duration_unit
        AND priced_prices.duration_value = :duration_value
      SQL

      Priced::Price.find_by_sql(
        [ within_sql, { start_date:, end_date:, duration_unit:, duration_value: } ]
      ).group_by(&:date).transform_values(&:first)
    end
  end
end
