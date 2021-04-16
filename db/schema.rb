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

ActiveRecord::Schema.define(version: 2021_04_15_132750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aps", force: :cascade do |t|
    t.string "installation_s3ic_id"
    t.string "description"
    t.date "date"
    t.string "url"
    t.bigint "installation_id", null: false
    t.index ["installation_id"], name: "index_aps_on_installation_id"
  end

  create_table "arretes", force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
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
    t.string "cid"
  end

  create_table "arretes_unique_classements", id: false, force: :cascade do |t|
    t.bigint "arrete_id", null: false
    t.bigint "unique_classement_id", null: false
  end

  create_table "classements", force: :cascade do |t|
    t.string "rubrique"
    t.string "regime"
    t.string "alinea"
    t.bigint "installation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "activite"
    t.date "date_autorisation"
    t.string "volume"
    t.string "seuil"
    t.string "rubrique_acte"
    t.string "regime_acte"
    t.string "alinea_acte"
    t.index ["installation_id"], name: "index_classements_on_installation_id"
  end

  create_table "enriched_arretes", force: :cascade do |t|
    t.jsonb "data"
    t.string "short_title"
    t.string "title"
    t.boolean "unique_version"
    t.string "installation_date_criterion_left"
    t.string "installation_date_criterion_right"
    t.string "aida_url"
    t.string "legifrance_url"
    t.jsonb "summary"
    t.bigint "arrete_id", null: false
    t.index ["arrete_id"], name: "index_enriched_arretes_on_arrete_id"
  end

  create_table "installations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "s3ic_id"
    t.string "region"
    t.string "department"
    t.string "zipcode"
    t.string "city"
    t.date "last_inspection"
    t.string "regime"
    t.string "seveso"
    t.string "state"
    t.bigint "user_id"
    t.bigint "duplicated_from_id"
    t.index ["user_id"], name: "index_installations_on_user_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.string "reference"
    t.string "content"
    t.string "alinea_id"
    t.bigint "from_am_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_prescriptions_on_user_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "unique_classements", force: :cascade do |t|
    t.string "rubrique"
    t.string "regime"
    t.string "alinea"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "aps", "installations"
  add_foreign_key "classements", "installations"
  add_foreign_key "enriched_arretes", "arretes"
  add_foreign_key "installations", "users"
  add_foreign_key "prescriptions", "users"
end
