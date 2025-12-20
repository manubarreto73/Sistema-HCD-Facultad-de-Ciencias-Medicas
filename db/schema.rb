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

ActiveRecord::Schema[8.0].define(version: 2025_12_19_010436) do
  create_table "daily_agenda_expedient_histories", force: :cascade do |t|
    t.integer "daily_agenda_id", null: false
    t.integer "expedient_id", null: false
    t.integer "previous_destination_id", null: false
    t.integer "new_destination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_agenda_id"], name: "index_daily_agenda_expedient_histories_on_daily_agenda_id"
    t.index ["expedient_id"], name: "index_daily_agenda_expedient_histories_on_expedient_id"
    t.index ["new_destination_id"], name: "index_daily_agenda_expedient_histories_on_new_destination_id"
    t.index ["previous_destination_id"], name: "idx_on_previous_destination_id_e010e9405a"
  end

  create_table "daily_agendas", force: :cascade do |t|
    t.integer "number", default: 0
    t.date "date", default: "2025-12-16", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "destination_id"
    t.index ["destination_id"], name: "index_daily_agendas_on_destination_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_commission", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_hcd", null: false
    t.integer "number_of_agendas", default: 1
    t.index ["is_hcd"], name: "unique_hcd_destination", unique: true, where: "is_hcd = true"
    t.index ["name"], name: "index_destinations_on_name", unique: true
  end

  create_table "expedient_histories", force: :cascade do |t|
    t.integer "expedient_id", null: false
    t.integer "user_id", null: false
    t.integer "action"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedient_id"], name: "index_expedient_histories_on_expedient_id"
    t.index ["user_id"], name: "index_expedient_histories_on_user_id"
  end

  create_table "expedients", force: :cascade do |t|
    t.string "file_number", null: false
    t.string "responsible", null: false
    t.string "detail", null: false
    t.string "opinion"
    t.datetime "creation_date"
    t.integer "file_status", default: 0
    t.datetime "treat_date"
    t.integer "destination_id"
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "daily_agenda_id"
    t.integer "position"
    t.index ["daily_agenda_id"], name: "index_expedients_on_daily_agenda_id"
    t.index ["destination_id"], name: "index_expedients_on_destination_id"
    t.index ["subject_id"], name: "index_expedients_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.integer "priority", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subjects_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "daily_agenda_expedient_histories", "daily_agendas"
  add_foreign_key "daily_agenda_expedient_histories", "destinations", column: "new_destination_id"
  add_foreign_key "daily_agenda_expedient_histories", "destinations", column: "previous_destination_id"
  add_foreign_key "daily_agenda_expedient_histories", "expedients"
  add_foreign_key "daily_agendas", "destinations"
  add_foreign_key "expedient_histories", "expedients"
  add_foreign_key "expedient_histories", "users"
  add_foreign_key "expedients", "daily_agendas"
  add_foreign_key "expedients", "destinations"
  add_foreign_key "expedients", "subjects"
end
