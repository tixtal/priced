module Priced
  module Adapters
    class Base
      class << self
        def extract_month(date)
          raise NotImplementedError
        end

        def extract_day(date)
          raise NotImplementedError
        end

        def extract_wday(date)
          raise NotImplementedError
        end

        def cast_to_date(date)
          raise NotImplementedError
        end
      end
    end
  end
end
