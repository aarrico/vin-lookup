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

ActiveRecord::Schema[8.1].define(version: 2026_06_06_120003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "dealer_inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.bigint "dealer_id", null: false
    t.integer "mileage"
    t.integer "price_cents"
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "vin", null: false
    t.index ["dealer_id", "vin"], name: "index_dealer_inventories_on_dealer_id_and_vin", unique: true
    t.index ["dealer_id"], name: "index_dealer_inventories_on_dealer_id"
    t.index ["vin"], name: "index_dealer_inventories_on_vin"
  end

  create_table "dealers", force: :cascade do |t|
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.text "display_config"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_dealers_on_api_key", unique: true
  end

  create_table "vehicle_lookups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "decoded_at", null: false
    t.text "raw_data", null: false
    t.datetime "updated_at", null: false
    t.string "vin", null: false
    t.index ["vin"], name: "index_vehicle_lookups_on_vin", unique: true
  end

  add_foreign_key "dealer_inventories", "dealers"
end
