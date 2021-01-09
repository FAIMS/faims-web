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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20170912060902) do

  create_table "background_jobs", :force => true do |t|
    t.string   "status"
    t.integer  "project_module_id"
    t.integer  "project_exporter_id"
    t.string   "job_type"
    t.integer  "user_id"
    t.string   "module_name"
    t.integer  "delayed_job_id"
    t.string   "failure_message"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "project_processor_id"
  end

  add_index "background_jobs", ["project_exporter_id"], :name => "index_background_jobs_on_project_exporter_id"
  add_index "background_jobs", ["project_module_id"], :name => "index_background_jobs_on_project_module_id"
  add_index "background_jobs", ["project_processor_id"], :name => "index_background_jobs_on_project_processor_id"
  add_index "background_jobs", ["user_id"], :name => "index_background_jobs_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "permissions", :force => true do |t|
    t.string   "entity"
    t.string   "action"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "project_module_exports", :force => true do |t|
    t.integer  "project_module_id"
    t.string   "exporter"
    t.text     "options"
    t.integer  "background_job_id"
    t.text     "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "project_module_exports", ["background_job_id"], :name => "index_project_module_exports_on_background_job_id"
  add_index "project_module_exports", ["exporter"], :name => "index_project_module_exports_on_exporter"
  add_index "project_module_exports", ["options"], :name => "index_project_module_exports_on_options"
  add_index "project_module_exports", ["project_module_id"], :name => "index_project_module_exports_on_project_module_id"

  create_table "project_module_processes", :force => true do |t|
    t.integer  "project_module_id"
    t.string   "processor"
    t.text     "options"
    t.text     "action"
    t.integer  "background_job_id"
    t.text     "uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "project_module_processes", ["background_job_id"], :name => "index_project_module_processes_on_background_job_id"
  add_index "project_module_processes", ["options"], :name => "index_project_module_processes_on_options"
  add_index "project_module_processes", ["processor"], :name => "index_project_module_processes_on_processor"
  add_index "project_module_processes", ["project_module_id"], :name => "index_project_module_processes_on_project_module_id"

  create_table "project_modules", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "key"
    t.boolean  "created"
    t.boolean  "deleted"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_permissions", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "user_modules", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_module_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "user_modules", ["project_module_id"], :name => "index_user_modules_on_project_module_id"
  add_index "user_modules", ["user_id"], :name => "index_user_modules_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "role_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.text     "module_password"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
