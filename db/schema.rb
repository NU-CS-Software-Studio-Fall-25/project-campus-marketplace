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

ActiveRecord::Schema[8.0].define(version: 2025_12_06_180000) do
  create_schema "_heroku"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.decimal "response_amount", precision: 10, scale: 2
    t.text "message"
    t.text "response_message"
    t.datetime "responded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_bids_on_buyer_id"
    t.index ["listing_id", "buyer_id"], name: "index_bids_on_listing_id_and_buyer_id"
    t.index ["listing_id"], name: "index_bids_on_listing_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_favorites_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "hidden_listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_hidden_listings_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_hidden_listings_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_hidden_listings_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", default: "other", null: false
    t.integer "favorites_count", default: 0, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "phone_number"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "reset_password_digest"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token_digest"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.string "google_uid"
    t.string "google_token"
    t.string "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.datetime "terms_accepted_at"
    t.index ["confirmation_token_digest"], name: "index_users_on_confirmation_token_digest"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["reset_password_digest"], name: "index_users_on_reset_password_digest"
    t.index ["terms_accepted_at"], name: "index_users_on_terms_accepted_at"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bids", "listings"
  add_foreign_key "bids", "users", column: "buyer_id"
  add_foreign_key "favorites", "listings"
  add_foreign_key "favorites", "users"
  add_foreign_key "hidden_listings", "listings"
  add_foreign_key "hidden_listings", "users"
  add_foreign_key "sessions", "users"
end
