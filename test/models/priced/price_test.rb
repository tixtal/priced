require "test_helper"

class Priced::PriceTest < ActiveSupport::TestCase
  test "validate presence of priceable" do
    price = Priced::Price.new
    assert_not price.valid?
    assert_includes price.errors.messages[:priceable], "must exist"
  end

  test "validate presence of price_type" do
    price = Priced::Price.new
    assert_not price.valid?
    assert_includes price.errors.messages[:price_type], "can't be blank"
  end

  test "validate length of price_cents" do
    price = Priced::Price.new(price: -1)

    assert_not price.valid?
    assert_includes price.errors.messages[:price], "must be greater than or equal to 0"
  end

  test "should validate uniqueness of price_type unless seasonal price" do
    price = Priced::Price.new(priceable: rooms(:single), price_type: :base)

    assert_not price.valid?
    assert_includes price.errors.messages[:price_type], "has already been taken"
  end

  test "should not validate uniqueness of price_type if not seasonal and duration is different" do
    price = Priced::Price.new(
      priceable: rooms(:single),
      price_type: :base,
      duration_unit: :weeks
    )

    assert price.valid?
  end
end
