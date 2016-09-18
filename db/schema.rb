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

ActiveRecord::Schema.define(version: 20160918011249) do

  create_table "collages", force: :cascade do |t|
    t.string   "path",       limit: 255
    t.string   "query",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "version_id", limit: 4
    t.string   "image_name", limit: 255
  end

  create_table "colors", force: :cascade do |t|
    t.string   "hex_code",    limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "palette_id",  limit: 4
    t.string   "description", limit: 255
  end

  add_index "colors", ["palette_id"], name: "index_colors_on_palette_id", using: :btree

  create_table "colors_palettes", id: false, force: :cascade do |t|
    t.integer "color_id",   limit: 4, null: false
    t.integer "palette_id", limit: 4, null: false
  end

  create_table "design_templates", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.text     "prompts",                    limit: 65535
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "original_file_file_name",    limit: 255
    t.string   "original_file_content_type", limit: 255
    t.integer  "original_file_file_size",    limit: 4
    t.datetime "original_file_updated_at"
    t.boolean  "is_trans_butt",              limit: 1,     default: false
    t.integer  "managed_asset_id",           limit: 4
    t.boolean  "has_been_post_processed",    limit: 1,     default: false
  end

  add_index "design_templates", ["managed_asset_id"], name: "index_design_templates_on_managed_asset_id", using: :btree

  create_table "managed_assets", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "design_template_id", limit: 4
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.string   "name",               limit: 255
    t.text     "description",        limit: 65535
  end

  add_index "managed_assets", ["design_template_id"], name: "index_managed_assets_on_design_template_id", using: :btree

  create_table "palettes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "color_id",    limit: 4
    t.string   "description", limit: 255
  end

  add_index "palettes", ["color_id"], name: "index_palettes_on_color_id", using: :btree

  create_table "replacement_images", force: :cascade do |t|
    t.integer  "version_id",                 limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "uploaded_file_file_name",    limit: 255
    t.string   "uploaded_file_content_type", limit: 255
    t.integer  "uploaded_file_file_size",    limit: 4
    t.datetime "uploaded_file_updated_at"
    t.string   "image_name",                 limit: 255
    t.string   "url",                        limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string   "output_folder_path", limit: 255
    t.text     "values",             limit: 65535
    t.integer  "design_template_id", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "name",               limit: 255
    t.datetime "last_render_date"
  end

  add_foreign_key "colors", "palettes"
  add_foreign_key "design_templates", "managed_assets"
  add_foreign_key "managed_assets", "design_templates"
  add_foreign_key "palettes", "colors"
end
