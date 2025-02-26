module Priced
  class Price < ApplicationRecord
    belongs_to :priceable, polymorphic: true

    enum :price_type, {
      base: "base",
      seasonal: "seasonal",
      weekend: "weekend"
    }, suffix: :price

    enum :duration_unit, {
      hours: "hours",
      days: "days",
      weeks: "weeks",
      months: "months",
      years: "years"
    }, prefix: :duration_unit, default: Priced.default_duration_unit

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
    scope :current, -> { active.at(Time.zone.today) }
    scope :at, lambda { |date|
      where(Query.match_price_type_at(date))
    }

    monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }

    after_initialize -> { self.duration_value = Priced.default_duration_value },
                        unless: :duration_value?

    validates :price_type, presence: true
    validates :price_type,
              uniqueness: {
                scope: %i[duration_unit duration_value priceable_id priceable_type active]
              }, if: -> { active? && !seasonal_price? }
    validates :start_date, :end_date, presence: true, if: :non_recurring_season?
    validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, if: :non_recurring_season?
    validate :dates_not_overlapped, if: :non_recurring_season?
    validates :recurring_start_month, :recurring_end_month, presence: true, if: :recurring_season?
    validates :recurring_start_day, :recurring_end_day, presence: true,
              if: -> { recurring_season? && !recurring_start_wday? && !recurring_end_wday? }
    validates :recurring_start_wday, :recurring_end_wday, presence: true,
              if: -> { recurring_season? && !recurring_start_day? && !recurring_end_day? }

    def active?
      active
    end

    def inactive?
      !active?
    end

    def recurring_season?
      seasonal_price? && recurring?
    end

    def non_recurring_season?
      seasonal_price? && !recurring?
    end

    private

    def dates_not_overlapped
      overlaped = self.class
                      .active
                      .where(priceable:, price_type:, duration_unit:, duration_value:)
                      .where.not(id:)
                      .where(
                        "start_date <= :end_date AND end_date >= :start_date",
                        start_date:,
                        end_date:
                      ).exists?

      return unless overlaped

      errors.add(:start_date, "dates are overlapping with other active seasonal prices")
      errors.add(:end_date, "dates are overlapping with other active seasonal prices")
    end
  end
end
