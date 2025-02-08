require "test_helper"

class PriceableTest < ActiveSupport::TestCase
  test "should be able to get base price" do
    priceable = rooms(:single)
    base_price = priced_prices(:single_room_base_price)

    assert priceable.current_base_price.present?
    assert_equal base_price, priceable.current_base_price
  end

  test "should not be able to get base price if no base price" do
    base_price_for_deluxe = priced_prices(:deluxe_room_base_price)
    base_price_for_deluxe.destroy

    priceable = rooms(:deluxe)

    assert_nil priceable.current_base_price
  end

  test "should be able to get current price as base price" do
    Priced.weekend_days = [ Time.zone.today.wday + 1, Time.zone.today.wday + 2 ]
    priceable = rooms(:single)

    assert_equal priceable.current_base_price, priceable.current_price
  end

  test "should be able to get current price as seasonal price" do
    seasonal_price = priced_prices(:single_room_seasonal_price)
    seasonal_price.update(start_date: Time.zone.today - 1.day, end_date: Time.zone.today + 1.day)

    priceable = rooms(:single)

    assert_equal seasonal_price, priceable.current_price
  end

  test "should be able to get current price as weekend price" do
    Priced.weekend_days = [ Time.zone.today.wday, Time.zone.today.wday + 1 ]
    weekend_price = priced_prices(:single_room_weekend_price)

    priceable = rooms(:single)

    assert_equal weekend_price, priceable.current_price
  end

  test "should be able to get current price as weekend price if no seasonal price" do
    Priced.weekend_days = [ Time.zone.today.wday, Time.zone.today.wday + 1 ]
    seasonal_price = priced_prices(:single_room_seasonal_price)
    seasonal_price.update(start_date: Time.zone.today + 1.day, end_date: Time.zone.today + 2.days)

    weekend_price = priced_prices(:single_room_weekend_price)

    priceable = rooms(:single)

    assert_equal weekend_price, priceable.current_price
  end

  test "should get seasonal price on weekend" do
    Priced.weekend_days = [ Time.zone.today.wday, Time.zone.today.wday + 1 ]
    seasonal_price = priced_prices(:single_room_seasonal_price)
    seasonal_price.update(start_date: Time.zone.today - 1.day, end_date: Time.zone.today + 1.day)

    priceable = rooms(:single)

    assert_equal seasonal_price, priceable.current_price
  end
end
