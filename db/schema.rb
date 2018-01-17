# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180111161500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "course_event_indicators", force: :cascade do |t|
    t.uuid "course_uuid", null: false
    t.integer "last_course_seqnum", null: false
    t.boolean "needs_attention", null: false
    t.datetime "waiting_since", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_uuid"], name: "index_course_event_indicators_on_course_uuid", unique: true
    t.index ["needs_attention", "waiting_since"], name: "index_ceis_on_na_ws"
    t.index ["needs_attention"], name: "index_course_event_indicators_on_needs_attention"
    t.index ["waiting_since"], name: "index_course_event_indicators_on_waiting_since"
  end

  create_table "course_events", force: :cascade do |t|
    t.uuid "event_uuid", null: false
    t.string "event_type", null: false
    t.uuid "course_uuid", null: false
    t.integer "course_seqnum", null: false
    t.jsonb "data", null: false
    t.boolean "has_been_processed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_uuid", "course_seqnum"], name: "index_course_events_on_course_uuid_and_course_seqnum", unique: true
    t.index ["course_uuid", "has_been_processed", "course_seqnum"], name: "index_ces_on_cu_hbp_csn"
    t.index ["course_uuid"], name: "index_course_events_on_course_uuid"
    t.index ["event_uuid", "has_been_processed", "course_seqnum"], name: "index_ces_on_eu_hbp_csn"
    t.index ["event_uuid"], name: "index_course_events_on_event_uuid", unique: true
    t.index ["has_been_processed", "course_uuid", "course_seqnum"], name: "index_ces_on_hbp_cu_csn"
    t.index ["has_been_processed"], name: "index_course_events_on_has_been_processed"
  end

end
