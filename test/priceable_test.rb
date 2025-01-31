require "test_helper"

class PriceableTest < ActiveSupport::TestCase
  test "should be able to get base price" do
    priceable = rooms(:single)
    base_price = priced_prices(:single_room_base_price)

    assert priceable.base_price.present?
    assert_equal base_price, priceable.base_price
  end
end