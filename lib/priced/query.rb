module Priced
  class Query
    class << self
      def adapter
        case ActiveRecord::Base.connection.adapter_name.downcase.to_sym
        when :postgresql, :postgis
          Priced::Adapters::PostgreSQL
        when :mysql
          Priced::Adapters::MySQL
        when :sqlite
          Priced::Adapters::SQLite
        else
          raise "Unsupported database adapter"
        end
      end

      def prices_within(start_date, end_date)
        <<-SQL.squish
          WITH RECURSIVE dates AS (
            SELECT #{adapter.cast_to_date(start_date)} AS date
            UNION ALL
            SELECT #{adapter.add_date_days('date', 1)} AS date
            FROM dates
            WHERE date < #{adapter.cast_to_date(end_date)}
          )

          SELECT dates.date, priced_prices.* FROM dates
          INNER JOIN priced_prices
          ON #{match_prices_at('dates.date')}
        SQL
      end

      def match_prices_at(date)
        <<-SQL.squish
          (
            SELECT
            CASE
            WHEN EXISTS (
              SELECT 1 FROM priced_prices AS non_recurring_seasonal_prices
              WHERE non_recurring_seasonal_prices.priceable_id = priced_prices.priceable_id
              AND non_recurring_seasonal_prices.priceable_type = priced_prices.priceable_type
              AND #{match_non_recurring_seasonal_prices_at(date)}
            ) THEN #{match_non_recurring_seasonal_prices_at(date)}
            WHEN EXISTS (
              SELECT 1 FROM priced_prices AS recurring_seasonal_prices
              WHERE recurring_seasonal_prices.priceable_id = priced_prices.priceable_id
              AND recurring_seasonal_prices.priceable_type = priced_prices.priceable_type
              AND #{match_recurring_seasonal_prices_at(date)}
            ) THEN #{match_recurring_seasonal_prices_at(date)}
            WHEN EXISTS (
              SELECT 1 FROM priced_prices AS weekend_prices
              WHERE weekend_prices.priceable_id = priced_prices.priceable_id
              AND weekend_prices.priceable_type = priced_prices.priceable_type
              AND #{match_weekend_prices_at(date)}
            ) THEN #{match_weekend_prices_at(date)}
            ELSE #{match_base_prices}
            END
          )
        SQL
      end

      def match_non_recurring_seasonal_prices_at(date)
        <<-SQL.squish
          price_type = 'seasonal'
          AND recurring IS FALSE
          AND start_date <= #{adapter.cast_to_date(date)}
          AND end_date >= #{adapter.cast_to_date(date)}
        SQL
      end

      def match_recurring_seasonal_prices_at(date)
        <<-SQL.squish
          price_type = 'seasonal'
          AND recurring IS TRUE
          AND #{adapter.extract_month(date)} >= recurring_start_month
          AND #{adapter.extract_month(date)} <= recurring_end_month
          AND recurring_start_day IS NOT NULL
          AND recurring_end_day IS NOT NULL
          AND #{adapter.extract_day(date)} >= recurring_start_day
          AND #{adapter.extract_day(date)} <= recurring_end_day
        SQL
      end

      def match_weekend_prices_at(date)
        weekend_days = Date::WEEKEND_DAYS.join(", ")

        <<-SQL.squish
          price_type = 'weekend'
          AND #{adapter.extract_wday(date)} IN (#{weekend_days})
        SQL
      end

      def match_base_prices
        "price_type = 'base'"
      end
    end
  end
end
