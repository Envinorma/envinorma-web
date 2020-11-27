# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_27_142859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arretes", force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
    t.bigint "installation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "short_title"
    t.string "title"
    t.boolean "unique_version"
    t.string "installation_date_criterion_left"
    t.string "installation_date_criterion_right"
    t.string "aida_url"
    t.string "legifrance_url"
    t.jsonb "summary"
    t.index ["installation_id"], name: "index_arretes_on_installation_id"
  end

  create_table "classements", force: :cascade do |t|
    t.string "rubrique"
    t.string "regime"
    t.string "alinea"
    t.bigint "installation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "activite"
    t.index ["installation_id"], name: "index_classements_on_installation_id"
  end

  create_table "installations", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "arretes", "installations"
  add_foreign_key "classements", "installations"
end
