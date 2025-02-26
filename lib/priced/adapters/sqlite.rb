module Priced
  module Adapters
    class SQLite < Base
      class << self
        def extract_month(date)
          "CAST(strftime('%m', #{date}) AS INTEGER)"
        end

        def extract_day(date)
          "CAST(strftime('%d', #{date}) AS INTEGER)"
        end

        def extract_wday(date)
          "CAST(strftime('%w', #{date}) AS INTEGER)"
        end

        def cast_to_date(date)
          "date(#{date})"
        end
      end
    end
  end
end
