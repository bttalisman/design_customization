# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160419160147) do

  create_table "collages", force: :cascade do |t|
    t.string   "path"
    t.string   "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "version_id"
  end

  create_table "colors", force: :cascade do |t|
    t.string   "hex_code"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "palette_id"
    t.string   "description"
  end

  add_index "colors", ["palette_id"], name: "index_colors_on_palette_id"

  create_table "colors_palettes", id: false, force: :cascade do |t|
    t.integer "color_id",   null: false
    t.integer "palette_id", null: false
  end

# Could not dump table "design_templates" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "palettes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "color_id"
    t.string   "description"
  end

  add_index "palettes", ["color_id"], name: "index_palettes_on_color_id"

  create_table "replacement_images", force: :cascade do |t|
    t.integer  "version_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

# Could not dump table "versions" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

end
