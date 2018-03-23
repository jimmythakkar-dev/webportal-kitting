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

ActiveRecord::Schema.define(:version => 20150427054349) do

  create_table "agusta_aircraft_details", :force => true do |t|
    t.string   "customer_number"
    t.string   "aircraft_id"
    t.text     "kit_part_numbers"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "agusta_aircraft_details", ["aircraft_id", "customer_number"], :name => "i_agu_air_det_air_id_cus_num"

  create_table "agusta_stations", :force => true do |t|
    t.string   "name"
    t.string   "station_type"
    t.string   "customer_number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "agusta_stations", ["name", "station_type", "customer_number"], :name => "i_agu_sta_nam_sta_typ_cus_num"

  create_table "cardex_kits", :force => true do |t|
    t.string   "kit_number"
    t.string   "parent_kit_id"
    t.integer  "kit_media_type_id", :precision => 38, :scale => 0
    t.text     "kit_html_layout"
    t.string   "box_number"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  create_table "cup_parts", :force => true do |t|
    t.integer  "cup_id",          :precision => 38, :scale => 0
    t.integer  "part_id",         :precision => 38, :scale => 0
    t.string   "demand_quantity"
    t.boolean  "status",          :precision => 1,  :scale => 0, :default => true
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "commit_id",       :precision => 38, :scale => 0
    t.boolean  "commit_status",   :precision => 1,  :scale => 0
    t.string   "uom"
    t.boolean  "in_contract",     :precision => 1,  :scale => 0, :default => true
  end

  add_index "cup_parts", ["cup_id", "part_id"], :name => "i_cup_parts_cup_id_part_id"

  create_table "cups", :force => true do |t|
    t.integer  "kit_id",        :precision => 38, :scale => 0
    t.boolean  "status",        :precision => 1,  :scale => 0
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "ref1"
    t.string   "ref2"
    t.string   "ref3"
    t.integer  "commit_id",     :precision => 38, :scale => 0
    t.boolean  "commit_status", :precision => 1,  :scale => 0
    t.string   "cup_dimension"
    t.integer  "cup_number",    :precision => 38, :scale => 0
  end

  add_index "cups", ["kit_id", "commit_id"], :name => "i_cups_kit_id_commit_id"

  create_table "customer_configurations", :force => true do |t|
    t.string   "cust_no"
    t.string   "cust_name"
    t.boolean  "non_contract_part",            :precision => 1, :scale => 0, :default => false
    t.boolean  "prevent_kit_copy",             :precision => 1, :scale => 0, :default => false
    t.boolean  "multiple_part",                :precision => 1, :scale => 0, :default => false
    t.string   "updated_by"
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.string   "default_kit_bin_center"
    t.string   "default_part_bin_center"
    t.string   "kitting_type"
    t.boolean  "invoicing_required",           :precision => 1, :scale => 0, :default => true
    t.string   "default_crib_part_bin_center"
  end

  add_index "customer_configurations", ["cust_no"], :name => "index_cust_config_cust_no"

  create_table "customers", :force => true do |t|
    t.string   "cust_no"
    t.string   "cust_name"
    t.string   "user_name"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "user_level"
    t.string   "user_type"
    t.text     "accounts"
    t.string   "vendor_no"
    t.string   "partner_no"
    t.text     "upload_configuration"
  end

  add_index "customers", ["cust_no"], :name => "index_customers_on_cust_no"
  add_index "customers", ["user_name"], :name => "index_customers_on_user_name"

  create_table "kit_bom_bulk_operations", :force => true do |t|
    t.string   "operation_type"
    t.string   "file_path"
    t.string   "status"
    t.integer  "customer_id",     :precision => 38, :scale => 0
    t.string   "kit_number"
    t.string   "bin_center"
    t.string   "part_number"
    t.string   "new_part_number"
    t.string   "old_part_number"
    t.boolean  "is_downloaded",   :precision => 1,  :scale => 0, :default => false
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
  end

  add_index "kit_bom_bulk_operations", ["customer_id"], :name => "i_kit_bom_bul_ope_cus_id"
  add_index "kit_bom_bulk_operations", ["file_path"], :name => "index_bom_ops", :unique => true

  create_table "kit_copies", :force => true do |t|
    t.integer  "kit_id",             :precision => 38, :scale => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "kit_version_number"
    t.integer  "location_id",        :precision => 38, :scale => 0
    t.integer  "status",             :precision => 38, :scale => 0
    t.integer  "customer_id",        :precision => 38, :scale => 0
    t.string   "version_status"
    t.string   "rfid_number"
  end

  add_index "kit_copies", ["kit_id", "location_id", "customer_id"], :name => "i_kit_cop_kit_id_loc_id_cus_id"
  add_index "kit_copies", ["rfid_number"], :name => "i_kit_copies_rfid_number", :unique => true

  create_table "kit_filling_details", :force => true do |t|
    t.integer  "kit_filling_id",  :precision => 38, :scale => 0
    t.integer  "cup_part_id",     :precision => 38, :scale => 0
    t.string   "filled_quantity"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "turn_count",      :precision => 38, :scale => 0, :default => 0
    t.string   "filled_state"
    t.string   "pack_id"
    t.string   "bin_location"
    t.boolean  "receive_flag",    :precision => 1,  :scale => 0, :default => false
    t.string   "receive_type"
  end

  create_table "kit_filling_history_reports", :force => true do |t|
    t.string   "kit_number"
    t.string   "kit_copy_number"
    t.string   "customer_number"
    t.integer  "cup_no",                 :precision => 38, :scale => 0
    t.string   "part_number"
    t.string   "demand_qty"
    t.string   "filled_qty"
    t.string   "created_by"
    t.datetime "filling_date"
    t.integer  "kit_filling_id",         :precision => 38, :scale => 0
    t.integer  "cup_part_id",            :precision => 38, :scale => 0
    t.integer  "cup_part_status",        :precision => 38, :scale => 0
    t.integer  "cup_part_commit_status", :precision => 38, :scale => 0
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "actual_qty"
    t.integer  "kit_work_order_id",      :precision => 38, :scale => 0
  end

  create_table "kit_fillings", :force => true do |t|
    t.integer  "kit_copy_id",       :precision => 38, :scale => 0
    t.integer  "location_id",       :precision => 38, :scale => 0
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.integer  "filled_state",      :precision => 38, :scale => 0
    t.string   "created_by"
    t.boolean  "flag",              :precision => 1,  :scale => 0
    t.integer  "customer_id",       :precision => 38, :scale => 0
    t.string   "received"
    t.string   "rbo_status",                                       :default => "Revoked"
    t.integer  "kit_work_order_id", :precision => 38, :scale => 0
  end

  add_index "kit_fillings", ["customer_id"], :name => "i_kit_fillings_customer_id"
  add_index "kit_fillings", ["kit_copy_id"], :name => "i_kit_fillings_kit_copy_id"
  add_index "kit_fillings", ["location_id"], :name => "i_kit_fillings_location_id"

  create_table "kit_media_types", :force => true do |t|
    t.string   "name"
    t.integer  "compartment",        :precision => 38, :scale => 0
    t.string   "kit_type"
    t.text     "description"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "compartment_layout"
    t.string   "customer_number"
    t.string   "customer_name"
    t.integer  "customer_id",        :precision => 38, :scale => 0
  end

  add_index "kit_media_types", ["customer_id"], :name => "i_kit_media_types_customer_id"

  create_table "kit_version_tracks", :force => true do |t|
    t.binary   "kit"
    t.binary   "cups"
    t.binary   "cup_parts"
    t.string   "kit_version"
    t.integer  "kit_id",      :precision => 38, :scale => 0
    t.string   "kit_number"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "kit_version_tracks", ["kit_id"], :name => "i_kit_version_tracks_kit_id"

  create_table "kit_work_orders", :force => true do |t|
    t.integer  "kit_id",        :precision => 38, :scale => 0
    t.integer  "work_order_id", :precision => 38, :scale => 0
    t.datetime "due_date"
    t.integer  "location_id",   :precision => 38, :scale => 0
    t.string   "created_by"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "kits", :force => true do |t|
    t.integer  "kit_media_type_id",                        :precision => 38, :scale => 0
    t.string   "kit_number"
    t.integer  "status",                                   :precision => 38, :scale => 0
    t.datetime "created_at",                                                                                 :null => false
    t.datetime "updated_at",                                                                                 :null => false
    t.string   "cust_no"
    t.string   "bincenter"
    t.integer  "customer_id",                              :precision => 38, :scale => 0
    t.string   "notes",                    :limit => 4000
    t.string   "description"
    t.integer  "commit_id",                                :precision => 38, :scale => 0
    t.boolean  "commit_status",                            :precision => 1,  :scale => 0
    t.string   "current_version"
    t.string   "edit_status"
    t.string   "part_bincenter"
    t.integer  "created_by",                               :precision => 38, :scale => 0
    t.integer  "updated_by",                               :precision => 38, :scale => 0
    t.integer  "parent_kit_id",                            :precision => 38, :scale => 0
    t.boolean  "deleted",                                  :precision => 1,  :scale => 0, :default => false
    t.string   "category"
    t.string   "customer_kit_part_number"
  end

  add_index "kits", ["kit_media_type_id"], :name => "i_kits_kit_media_type_id"
  add_index "kits", ["kit_number", "customer_id"], :name => "i_kits_kit_number_customer_id"

  create_table "kitting_kit_order_fulfillments", :force => true do |t|
    t.integer  "kit_filling_id",    :precision => 38, :scale => 0
    t.string   "kit_copy_number"
    t.string   "kit_number"
    t.string   "user_name"
    t.string   "cust_name"
    t.integer  "filled_state",      :precision => 38, :scale => 0
    t.string   "location_name"
    t.string   "order_no_closed"
    t.string   "scancode_closed"
    t.text     "order_no_received"
    t.text     "scancode_received"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.string   "box_id"
    t.string   "cust_no"
    t.integer  "kit_work_order_id", :precision => 38, :scale => 0
    t.string   "delivery_point"
    t.datetime "delivery_date"
    t.boolean  "delivered",         :precision => 1,  :scale => 0, :default => false
  end

  create_table "kitting_kit_status_details", :force => true do |t|
    t.integer  "kit_id",      :precision => 38, :scale => 0
    t.integer  "kit_copy_id", :precision => 38, :scale => 0
    t.string   "updated_by"
    t.string   "reason"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "kitting_pick_histories", :force => true do |t|
    t.string   "kit_number"
    t.string   "bincenter"
    t.integer  "kit_copy_id",    :precision => 38, :scale => 0
    t.string   "binlocation"
    t.string   "ordernolist"
    t.integer  "cup_id",         :precision => 38, :scale => 0
    t.string   "part_number"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "kit_filling_id", :precision => 38, :scale => 0
    t.boolean  "flag",           :precision => 1,  :scale => 0, :default => false
    t.integer  "box_number",     :precision => 38, :scale => 0
  end

  create_table "kitting_turn_report_details", :force => true do |t|
    t.string   "kit_number"
    t.string   "kit_description"
    t.integer  "cup_no",           :precision => 38, :scale => 0
    t.string   "part_number"
    t.integer  "turns_copy1",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy2",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy3",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy4",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy5",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy6",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy7",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy8",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy9",      :precision => 38, :scale => 0, :default => 0
    t.integer  "turns_copy10",     :precision => 38, :scale => 0, :default => 0
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.string   "kit_media_type"
    t.string   "part_description"
    t.string   "cust_no"
    t.string   "sub_kit_number"
  end

  create_table "locations", :force => true do |t|
    t.string   "name",            :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "customer_number"
  end

  add_index "locations", ["name"], :name => "index_locations_on_name"

  create_table "order_part_details", :force => true do |t|
    t.integer  "order_id",              :precision => 38, :scale => 0
    t.string   "part_number",                                                             :null => false
    t.string   "reason_code"
    t.string   "note"
    t.datetime "fulfilment_date_time"
    t.datetime "shipment_date_time"
    t.string   "carrier_name"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.string   "uom"
    t.string   "filled_state"
    t.datetime "cancellation_date"
    t.integer  "kit_filling_detail_id", :precision => 38, :scale => 0
    t.string   "bin_location"
    t.string   "pack_id"
    t.integer  "location_id",           :precision => 38, :scale => 0
    t.boolean  "received_flag",         :precision => 1,  :scale => 0, :default => false
    t.string   "quantity"
    t.string   "delivery_point"
    t.datetime "delivery_date"
    t.boolean  "delivered",             :precision => 1,  :scale => 0, :default => false
  end

  add_index "order_part_details", ["created_at"], :name => "i_ord_par_det_cre_at"
  add_index "order_part_details", ["order_id"], :name => "i_order_part_details_order_id"
  add_index "order_part_details", ["updated_at"], :name => "i_ord_par_det_upd_at"

  create_table "orders", :force => true do |t|
    t.string   "order_number"
    t.string   "order_type",                                                             :null => false
    t.string   "order_status"
    t.string   "customer_name",                                                          :null => false
    t.string   "customer_number",                                                        :null => false
    t.string   "project_id",                                                             :null => false
    t.string   "station_name",                                                           :null => false
    t.string   "discharge_point_name",                                                   :null => false
    t.string   "kit_part_number",                                                        :null => false
    t.string   "created_by",                                                             :null => false
    t.string   "updated_by"
    t.string   "remark"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.datetime "due_date"
    t.integer  "kit_filling_id",       :precision => 38, :scale => 0
    t.datetime "cancellation_date"
    t.boolean  "auto_cancelled",       :precision => 1,  :scale => 0, :default => false
  end

  add_index "orders", ["created_at"], :name => "index_orders_on_created_at"
  add_index "orders", ["customer_number"], :name => "i_orders_customer_number"
  add_index "orders", ["order_number"], :name => "index_orders_on_order_number"
  add_index "orders", ["updated_at"], :name => "index_orders_on_updated_at"

  create_table "parts", :force => true do |t|
    t.string   "part_number"
    t.string   "image_name"
    t.text     "description"
    t.boolean  "status",           :precision => 1,  :scale => 0, :default => true
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.string   "name"
    t.string   "customer_number"
    t.integer  "large_cup_count",  :precision => 38, :scale => 0
    t.integer  "medium_cup_count", :precision => 38, :scale => 0
    t.integer  "small_cup_count",  :precision => 38, :scale => 0
    t.string   "prime_pn"
  end

  add_index "parts", ["part_number"], :name => "index_parts_on_part_number", :unique => true

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.string   "cust_no"
    t.string   "description"
    t.string   "file_name"
    t.string   "uploaded_by"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "returned_part_details", :force => true do |t|
    t.string   "work_order"
    t.string   "job_card_number"
    t.string   "job_card_description"
    t.string   "stage"
    t.string   "serial_number"
    t.string   "part_number"
    t.string   "quantity"
    t.datetime "date_completed"
    t.string   "request_type"
    t.string   "requestor"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "cust_no"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "track_copy_versions", :force => true do |t|
    t.integer  "kit_copy_id",    :precision => 38, :scale => 0
    t.string   "version"
    t.string   "picked_version"
    t.string   "filled_version"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "track_copy_versions", ["kit_copy_id"], :name => "i_tra_cop_ver_kit_cop_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",                                 :null => false
    t.integer  "item_id",    :precision => 38, :scale => 0, :null => false
    t.string   "event",                                     :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "i_versions_item_type_item_id"

  create_table "work_orders", :force => true do |t|
    t.string   "order_number",  :null => false
    t.string   "stage"
    t.string   "serial_number"
    t.string   "created_by"
    t.string   "updated_by"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
