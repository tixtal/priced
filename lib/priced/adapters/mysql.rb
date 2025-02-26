module Priced
  module Adapters
    class MySQL < Base
      class << self
        def extract_month(date)
          "MONTH(#{date})"
        end

        def extract_day(date)
          "DAY(#{date})"
        end

        def extract_wday(date)
          "WEEKDAY(#{date})"
        end

        def cast_to_date(date)
          "DATE(#{date})"
        end

        def add_date_days(date, days)
          "DATE_ADD(#{date}, INTERVAL #{days} DAY)"
        end
      end
    end
  end
end
