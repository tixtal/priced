module Priced
  module Adapters
    class PostgreSQL < Base
      class << self
        def extract_month(date)
          "EXTRACT(MONTH FROM #{date}::date)"
        end

        def extract_day(date)
          "EXTRACT(DAY FROM #{date}::date)"
        end

        def extract_wday(date)
          "EXTRACT(DOW FROM #{date}::date)"
        end

        def cast_to_date(date)
          "#{date}::date"
        end
      end
    end
  end
end
