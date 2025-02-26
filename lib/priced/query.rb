module Priced
  class Query
    class << self
      def seasonal_price_at(date)
        month = date.month
        day = date.day
        wday = date.wday

        Arel.sql(seasonal_price_at_sql, date:, month:, day:, wday:)
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
end