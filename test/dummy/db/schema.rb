# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_09_194334) do
  create_table "priced_prices", force: :cascade do |t|
    t.string "priceable_type", null: false
    t.integer "priceable_id", null: false
    t.string "price_type"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.string "duration_unit"
    t.integer "duration_value"
    t.date "start_date"
    t.date "end_date"
    t.boolean "recurring", default: false
    t.integer "recurring_start_month"
    t.integer "recurring_start_day"
    t.integer "recurring_end_month"
    t.integer "recurring_end_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["duration_unit", "duration_value"], name: "index_priced_prices_on_duration"
    t.index ["price_type"], name: "index_priced_prices_on_price_type"
    t.index ["priceable_type", "priceable_id"], name: "index_priced_prices_on_priceable"
    t.index ["recurring_start_day", "recurring_end_day"], name: "index_priced_prices_on_recurring_days"
    t.index ["recurring_start_month", "recurring_end_month"], name: "index_priced_prices_on_recurring_months"
    t.index ["start_date", "end_date"], name: "index_priced_prices_on_dates"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
