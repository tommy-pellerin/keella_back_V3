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

ActiveRecord::Schema[8.0].define(version: 2024_11_15_134750) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.bigint "workout_id"
    t.datetime "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "max_participants"
    t.integer "slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_id"], name: "index_availabilities_on_workout_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "participant_id", null: false
    t.bigint "availability_id", null: false
    t.integer "quantity"
    t.float "total"
    t.integer "status", default: 0
    t.integer "cancellation_reason"
    t.datetime "status_changed_at"
    t.datetime "relaunched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability_id"], name: "index_reservations_on_availability_id"
    t.index ["participant_id"], name: "index_reservations_on_participant_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "birthday"
    t.string "phone"
    t.bigint "city_id"
    t.boolean "id_verified", default: false
    t.boolean "professional", default: false
    t.boolean "is_admin", default: false
    t.integer "status", default: 0
    t.index ["city_id"], name: "index_users_on_city_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "equipments"
    t.string "address"
    t.bigint "city_id"
    t.integer "max_participants"
    t.integer "duration_per_session", default: 60
    t.decimal "price_per_session", default: "0.0"
    t.bigint "host_id"
    t.bigint "category_id"
    t.boolean "is_indoor", default: true
    t.boolean "host_present", default: true
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_workouts_on_category_id"
    t.index ["city_id"], name: "index_workouts_on_city_id"
    t.index ["host_id"], name: "index_workouts_on_host_id"
  end

  add_foreign_key "reservations", "availabilities"
  add_foreign_key "reservations", "users", column: "participant_id"
  add_foreign_key "users", "cities"
  add_foreign_key "workouts", "users", column: "host_id"
end
