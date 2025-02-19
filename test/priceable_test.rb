require "test_helper"

class PriceableTest < ActiveSupport::TestCase
  test "should be able to get base price" do
    priceable = rooms(:single)
    base_price = priced_prices(:single_room_base_price)

    assert priceable.base_price.present?
    assert_equal base_price, priceable.base_price
  end

  test "should not be able to get base price if no base price" do
    base_price_for_deluxe = priced_prices(:deluxe_room_base_price)
    base_price_for_deluxe.destroy

    priceable = rooms(:deluxe)

    assert_nil priceable.base_price
  end

  test "should be able to get current price as base price" do
    Priced.weekend_days = [ Time.zone.today.wday + 1, Time.zone.today.wday + 2 ]
    priceable = rooms(:single)

    assert_equal priceable.base_price, priceable.current_price
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

  test "should be able to build base price" do
    priceable = rooms(:single)
    base_price = priceable.base_prices.build

    assert base_price.base_price?
  end

  test "should be able to build seasonal price" do
    priceable = rooms(:single)

    seasonal_price = priceable.seasonal_prices.build(
      start_date: Time.zone.today,
      end_date: Time.zone.today + 1.day
    )

    assert seasonal_price.seasonal_price?
  end

  test "should be able to build weekend price" do
    priceable = rooms(:single)

    weekend_price = priceable.weekend_prices.build(
      duration_unit: :hours,
      duration_value: 1
    )

    assert weekend_price.weekend_price?
  end
end
