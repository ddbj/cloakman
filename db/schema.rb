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

ActiveRecord::Schema[8.0].define(version: 2025_01_21_003049) do
  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "ssh_keys", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "key", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ssh_keys_on_user_id"
  end

  create_table "uid_numbers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_uid_numbers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "first_name_japanese"
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "last_name_japanese"
    t.string "job_title"
    t.string "job_title_japanese"
    t.string "orcid"
    t.string "erad_id"
    t.string "organization", null: false
    t.string "organization_japanese"
    t.string "lab_fac_dep"
    t.string "lab_fac_dep_japanese"
    t.string "organization_url"
    t.string "country", null: false
    t.string "postal_code"
    t.string "prefecture"
    t.string "city", null: false
    t.string "street"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "ssh_keys", "users"
  add_foreign_key "uid_numbers", "users"
end
