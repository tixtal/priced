module Priced
  class Price < ApplicationRecord
    attribute :duration_unit, default: -> { Priced.default_duration_unit }
    attribute :duration_value, default: -> { Priced.default_duration_value }

    enum :price_type, {
      base: "base",
      seasonal: "seasonal",
      weekend: "weekend"
    }, suffix: :price

    belongs_to :priceable, polymorphic: true

    scope :current, -> { at(Time.zone.today) }
    scope :at, lambda { |date|
      sql = Query.match_prices_at(":date")

      where(sanitize_sql_for_conditions([ sql, date: ]))
    }

    monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }

    validates :price_type, presence: true
    validates :price_type,
              uniqueness: {
                scope: %i[duration_unit duration_value priceable_id priceable_type]
              }, if: -> { !seasonal_price? }
    validates :start_date, :end_date, presence: true, if: :non_recurring_season?
    validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, if: :non_recurring_season?
    validate :dates_not_overlapped, if: :non_recurring_season?
    validates :recurring_start_month, :recurring_end_month, presence: true, if: :recurring_season?
    validates :recurring_start_day, :recurring_end_day, presence: true,
              if: :recurring_season?

    def recurring_season?
      seasonal_price? && recurring?
    end

    def non_recurring_season?
      seasonal_price? && !recurring?
    end

    private

    def dates_not_overlapped
      overlaped = self.class
                      .where(priceable:, price_type:, duration_unit:, duration_value:)
                      .where.not(id:)
                      .where(
                        "start_date <= :end_date AND end_date >= :start_date",
                        start_date:,
                        end_date:
                      ).exists?

      return unless overlaped

      errors.add(:start_date, "dates are overlapping with other seasonal prices")
      errors.add(:end_date, "dates are overlapping with other seasonal prices")
    end
  end
end
