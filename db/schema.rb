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

ActiveRecord::Schema.define(version: 20140711191432) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "hstore"

  create_table "admins", force: true do |t|
    t.string "email",                  default: "", null: false
    t.string "encrypted_password",     default: "", null: false
    t.string "username",               default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  add_index "admins", ["username"], name: "index_admins_on_username", unique: true, using: :btree

  create_table "card_images", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "image_url",  null: false
    t.text "caption"
    t.uuid "card_id",    null: false
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "card_images", ["card_id"], name: "index_card_images_on_card_id", using: :btree

  create_table "cards", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "name",                                                               null: false
    t.text "description"
    t.uuid "stack_id",                                                           null: false
    t.uuid "user_id",                                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "short_id",       default: "nextval('cards_short_id_seq'::regclass)", null: false
    t.integer "score",          default: 0
    t.integer "flags_count",    default: 0
    t.integer "comments_count", default: 0
  end

  add_index "cards", ["score"], name: "index_cards_on_score", using: :btree
  add_index "cards", ["short_id"], name: "index_cards_on_short_id", using: :btree
  add_index "cards", ["stack_id"], name: "index_cards_on_stack_id", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "comments", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text "body"
    t.hstore "mentions"
    t.uuid "replying_id"
    t.uuid "card_id",                 null: false
    t.uuid "user_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "score",       default: 0
    t.integer "flags_count", default: 0
  end

  add_index "comments", ["card_id"], name: "index_comments_on_card_id", using: :btree
  add_index "comments", ["replying_id"], name: "index_comments_on_replying_id", using: :btree
  add_index "comments", ["score"], name: "index_comments_on_score", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "devices", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "access_token",    limit: 32, null: false
    t.string "device_type",     limit: 16
    t.datetime "last_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "user_id"
    t.string "push_token"
    t.string "sns_arn"
  end

  add_index "devices", ["access_token"], name: "index_devices_on_access_token", unique: true, using: :btree

  create_table "flags", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid "flaggable_id",               null: false
    t.string "flaggable_type",             null: false
    t.uuid "user_id",                    null: false
    t.integer "kind",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["flaggable_id", "flaggable_type", "user_id"], name: "index_flags_on_flaggable_id_and_flaggable_type_and_user_id", unique: true, using: :btree

  create_table "networks", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "provider",   null: false
    t.string "uid",        null: false
    t.string "token",      null: false
    t.uuid "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "secret"
  end

  add_index "networks", ["provider", "user_id"], name: "index_networks_on_provider_and_user_id", unique: true, using: :btree
  add_index "networks", ["uid"], name: "index_networks_on_uid", using: :btree

  create_table "stacks", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "name",                        null: false
    t.boolean "protected",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid "user_id"
    t.text "description"
  end

  add_index "stacks", ["name"], name: "index_stacks_on_name", unique: true, using: :btree

  create_table "subscriptions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid "user_id",    null: false
    t.uuid "stack_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["user_id", "stack_id"], name: "index_subscriptions_on_user_id_and_stack_id", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "email",                  default: "", null: false
    t.string "encrypted_password",     default: "", null: false
    t.string "username",               default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar_url"
    t.string "facebook_token"
    t.string "facebook_id"
    t.string "location"
    t.integer "flags_count",            default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["facebook_id"], name: "index_users_on_facebook_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "votes", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid "votable_id",                  null: false
    t.string "votable_type",                null: false
    t.uuid "user_id",                     null: false
    t.boolean "flag",         default: true
    t.integer "weight",       default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "user_id"], name: "index_votes_on_votable_id_and_votable_type_and_user_id", unique: true, using: :btree

end
