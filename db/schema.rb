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

ActiveRecord::Schema[8.1].define(version: 2026_08_14_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "banks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_banks_on_lower_name", unique: true
  end

  create_table "payment_advices", force: :cascade do |t|
    t.string "advice_no", null: false
    t.string "bank_name"
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.decimal "gross_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.date "invoice_date"
    t.string "invoice_no", null: false
    t.decimal "net_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "other_deduction", precision: 14, scale: 2, default: "0.0", null: false
    t.string "payee_email"
    t.string "payee_name", null: false
    t.date "payment_date"
    t.string "payment_mode", null: false
    t.string "reference_no"
    t.text "remarks"
    t.decimal "tds_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["advice_no"], name: "index_payment_advices_on_advice_no", unique: true
  end
end
