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

ActiveRecord::Schema.define(version: 2021_06_29_071922) do

  create_table "project_leaders", charset: "utf8", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "server_id"
    t.string "discord_user_id"
    t.index ["server_id"], name: "index_project_leaders_on_server_id"
  end

  create_table "projects", charset: "utf8", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_leader_id"
    t.string "name"
    t.bigint "server_id", null: false
    t.index ["project_leader_id"], name: "index_projects_on_project_leader_id"
    t.index ["server_id"], name: "index_projects_on_server_id"
  end

  create_table "servers", charset: "utf8", force: :cascade do |t|
    t.string "discord_server_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "task_to_tasks", id: false, charset: "utf8", force: :cascade do |t|
    t.bigint "parent_task_id"
    t.bigint "child_task_id"
  end

  create_table "tasks", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "description"
    t.string "assignee_discord_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_leader_id"
    t.index ["project_leader_id"], name: "index_tasks_on_project_leader_id"
  end

  add_foreign_key "project_leaders", "servers"
  add_foreign_key "projects", "servers"
  add_foreign_key "tasks", "project_leaders"
end
