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

ActiveRecord::Schema[8.1].define(version: 2025_11_11_094305) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "blogs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "published", default: false, null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "call_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration"
    t.string "error_message"
    t.string "from"
    t.string "status"
    t.string "to"
    t.string "twilio_sid"
    t.datetime "updated_at", null: false
  end
end
