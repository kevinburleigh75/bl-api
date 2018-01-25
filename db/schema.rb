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

ActiveRecord::Schema.define(version: 20180125195119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "course_event_indicators", force: :cascade do |t|
    t.uuid "course_uuid", null: false
    t.integer "course_last_bundled_seqnum", null: false
    t.boolean "course_needs_attention", null: false
    t.datetime "course_waiting_since", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_needs_attention", "course_waiting_since"], name: "index_ceis_on_cna_cws"
    t.index ["course_needs_attention"], name: "index_course_event_indicators_on_course_needs_attention"
    t.index ["course_uuid"], name: "index_course_event_indicators_on_course_uuid", unique: true
    t.index ["course_waiting_since"], name: "index_course_event_indicators_on_course_waiting_since"
  end

  create_table "course_events", force: :cascade do |t|
    t.uuid "event_uuid", null: false
    t.string "event_type", null: false
    t.jsonb "event_data", null: false
    t.boolean "event_has_been_bundled", null: false
    t.uuid "course_uuid", null: false
    t.integer "course_seqnum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_uuid", "course_seqnum"], name: "index_course_events_on_course_uuid_and_course_seqnum", unique: true
    t.index ["course_uuid", "event_has_been_bundled", "course_seqnum"], name: "index_ces_on_cu_ehbb_csn"
    t.index ["course_uuid"], name: "index_course_events_on_course_uuid"
    t.index ["event_has_been_bundled", "course_uuid", "course_seqnum"], name: "index_ces_on_ehbb_cu_csn"
    t.index ["event_has_been_bundled"], name: "index_course_events_on_event_has_been_bundled"
    t.index ["event_uuid", "event_has_been_bundled", "course_seqnum"], name: "index_ces_on_eu_ehbb_csn"
    t.index ["event_uuid"], name: "index_course_events_on_event_uuid", unique: true
  end

  create_table "ecosystem_events", force: :cascade do |t|
    t.uuid "event_uuid", null: false
    t.string "event_type", null: false
    t.jsonb "event_data", null: false
    t.uuid "ecosystem_uuid", null: false
    t.integer "ecosystem_seqnum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ecosystem_uuid", "ecosystem_seqnum"], name: "index_ecosystem_events_on_ecosystem_uuid_and_ecosystem_seqnum", unique: true
    t.index ["ecosystem_uuid", "event_type"], name: "index_ecosystem_events_on_ecosystem_uuid_and_event_type"
    t.index ["event_uuid"], name: "index_ecosystem_events_on_event_uuid", unique: true
  end

  create_table "student_clues", force: :cascade do |t|
    t.uuid "clue_uuid", null: false
    t.citext "clue_algorithm_name", null: false
    t.jsonb "clue_data", null: false
    t.uuid "student_uuid", null: false
    t.uuid "book_container_uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_container_uuid"], name: "index_student_clues_on_book_container_uuid", unique: true
    t.index ["clue_uuid"], name: "index_student_clues_on_clue_uuid", unique: true
    t.index ["student_uuid", "book_container_uuid", "clue_algorithm_name"], name: "index_scs_on_su_bcu_can", unique: true
  end

end
