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

ActiveRecord::Schema[8.0].define(version: 2025_07_19_154353) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

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

  create_table "order_items", force: :cascade do |t|
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.bigint "product_id", null: false
    t.bigint "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "idx_order_items_on_order_and_product", unique: true
    t.index ["order_id"], name: "idx_order_items_order_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "idx_order_items_product_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.check_constraint "quantity > 0", name: "constraint_order_items_quantity_positive"
    t.check_constraint "unit_price > 0::numeric", name: "constraint_order_items_unit_price_positive"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", limit: 50, default: "pending", null: false
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_orders_created_at"
    t.index ["status", "created_at"], name: "idx_orders_status_created_at"
    t.index ["status"], name: "idx_orders_status"
    t.index ["total_price"], name: "idx_orders_total_price"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "total_price >= 0::numeric", name: "constraint_orders_total_price_non_negative"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.text "description"
    t.integer "stock", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "searchable"
    t.index ["created_at", "price"], name: "idx_products_created_at_price"
    t.index ["created_at"], name: "idx_products_created_at"
    t.index ["searchable"], name: "gin_idx_products_on_searchable", using: :gin
    t.index ["stock", "price"], name: "idx_products_available_by_price", where: "(stock > 0)"
    t.index ["stock"], name: "idx_products_stock"
    t.check_constraint "length(name::text) >= 2", name: "constraint_products_name_min_length"
    t.check_constraint "price > 0::numeric", name: "constraint_products_price_positive"
    t.check_constraint "stock >= 0", name: "constraint_products_stock_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "order_items", "products", on_delete: :restrict
  add_foreign_key "orders", "users"
end
