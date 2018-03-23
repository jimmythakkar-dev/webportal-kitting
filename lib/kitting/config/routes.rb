Kitting::Engine.routes.draw do

  get "reports/index"
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  get "kit_filling_detail/show"
  get "kit_filling_detail/edit"
  match "admin/index"  => "admin#index"
  match "admin/cust_configs"  => "admin#cust_configs"
  match "admin/allow_customer_specific_changes"  => "admin#allow_customer_specific_changes"
  match "admin/edit_kit_description"  => "admin#edit_kit_description", :as => "edit_kit_description"
  match "admin/send_kit_description"  => "admin#send_kit_description", :as => "send_kit_description"
  match "admin/change_kit_status"  => "admin#change_kit_status"
  match "admin/submit_kit_status"  => "admin#submit_kit_status"
  post '/admin/store_inactive_checked_status/' => 'admin#store_inactive_checked_status'
  get '/cup_parts/add_parts_for_binder' => 'cup_parts#add_parts_for_binder'
  resources :locations

  resources :user_sessions

  resources :parts do
    collection do
      post :csv_import
      post :search
      get :image
      get :replace_parts
      post :replace_parts
      post :search_part
      get :part_status
      get :part_count_status
      get :upload
      get :download_sample
      get :csv_export
    end
  end

  match '/parts/get_part_number/:part_number' => 'parts#get_part_number', :as => "get_part_number"

  resources :kit_media_types do
    collection do
      get 'search_kit'
      post 'search_kit'
      post 'convert_media_type'
      post 'search_duplicate'
    end
  end

  match '/kits/detail_design' => 'kits#detail_design'
  match '/kits/kits_in_demand' => 'kits#kits_in_demand'
  match "/kit_copies/search" => "kit_copies#search", :as =>"kit_copy_search"
  match "/kit_copies/delete_copy" => "kit_copies#delete_copy", :as =>"kit_copy_delete"
  match "/kit_copies/update_queue" => "kit_copies#update_queue", :as =>"kit_queue_update"

  resources :kit_copies do
    collection do
      post 'pick_ticket_print'
      get 'pick_ticket_print'
      post 'print_label'
      get 'print_label'
      post 'print_change_data'
      post 'manage_rfid'
    end
    get 'pick_ticket', :on => :member
  end

  match "/kits/search" => "kits#search", :as =>"kit_search"
  resources :cardex_kits do
    collection do
      post 'search'
      get 'detail_design'
      post 'print_template'
      put 'save_layout'
      get 'build_part'
    end

    member do
      post :add_remove_mmt_kit
      get 'reset_layout'
    end
  end

  resources :kits, :constraints => { :id => /.*/ } do
    collection do
      post 'delete_upload_record'
      post 'part_look_up'
      get 'uom_look_up'
      get 'kits_approval'
      get 'approve_kits'
      post 'update_kit_details'
      post 'print_label'
      get 'new_copy', as: 'new_copy'
      post 'create_copy', as: 'create_copy'
      get 'detail_design_binder'
      post 'update_cardex'
      get 'kit_in_draft'
      get 'approval_show'
      get 'upload'
      get 'download_sample'
      get 'upload_status'
      post 'csv_import'
      post 'rfid_csv_import'
      get 'csv_export'
      post 'bailment_info_print'
      post 'delete_record'
      put 'update_kit_layout'
      put 'add_widget_kit_layout'
      get 'select_media_type'
      get 'add_media_type'
      post 'remove_media_type'
    end
  end

  # match '/add_queue/:kit/:location_id' => 'kits#add_queue', :as => "kit_queue"
  match '/filter_queue/:location_id' => 'kits#filter_queue', :as => "kit_filter"
  # match '/change_user/' => 'kits#change_user', :as => "change_user"

  resources :cups do
    get 'build'
    collection do
      get 'disable_cup'
    end
  end

  resources :kit_details do
    get "get_kit_parts_count"
  end
  post '/kit_details/store_selected_cup_ids/' => 'kit_details#store_selected_cup_ids'
  post '/kit_details/download_kit_copy_rfid/' => 'kit_details#download_kit_copy_rfid'

  resources :cup_parts do
    post 'update_quantity', :on => :collection
  end

  resources :kit_filling do
    post 'cup_filling', :on => :collection
    post 'kit_filling_create', :on => :member
    post 'kit_filling_edit', :on => :member
    get 'create_filling_show', :on => :member
    get 'search_parts'
    get 'edit_search_parts'
    get 'fill_all_cups', :on => :member
    get 'find_open_order'
  end

  get '/kit_copies/change_data/:id' => 'kit_copies#change_data'
  match '/kit_filling/reset_filled_kit/:id' => 'kit_filling#reset_filled_kit'
  match '/kit_filling_tracking_history/' => 'reports#kit_filling_tracking_history', :as => "kit_filling_tracking_history"
  match '/kit_filling/kit_status/:id' => 'kit_filling#kit_status'
  match '/kit_filling/kit_copy_status_update/:id' => 'kit_filling#kit_copy_status_update'
  get '/kit_filling/change_data/:id' => 'kit_filling#change_data'
  post '/kit_filling/print_change_data/' => 'kit_filling#print_change_data', :as => "kit_filling_print_change_data"
  match '/sos_pn_sortage/' => 'reports#sos_pn_sortage', :as => "sos_pn_sortage"
  match '/sos_kit_sortage/' => 'reports#sos_kit_sortage', :as => "sos_kit_sortage"
  match '/kit_filling/get_cup_changes/:id' => 'kit_filling#get_cup_changes'

  resources :reports

  get "kit_history", :to => "kit_history#show"
  get "kit_filling_history", :to => "kit_filling_history#show"
  match '/kit_receiving' => 'kit_receiving#index', :as => "kit_receiving"
  match "/kit_receiving/search" => "kit_receiving#search", :as =>"kit_receiving_search"
  match '/order_fulfillment_tracking/' => 'reports#order_fulfillment_tracking', :as => "order_fulfillment_tracking"
  match '/turn_count/' => 'reports#turn_count', :as => "turn_count"
  match '/newly_designed_kits/' => 'reports#newly_designed_kits', :as => "newly_designed_kits"
  match '/kit_fill_metrics/' => 'reports#kit_fill_metrics', :as => "kit_fill_metrics"
  match '/view_charts/' => 'reports#view_charts', :as => "view_charts"
  match '/sos_kits_in_process/' => 'reports#sos_kits_in_process', :as => "sos_kits_in_process"
  match '/returned_parts_details' => 'reports#returned_parts_details', :as => "returned_parts_details"
  match '/kit_work_order_status' => 'reports#kit_work_order_status', :as => "kit_work_order_status"
  match '/delivery' => 'reports#delivery', :as => "delivery"

  resources :crib_part_reports

  match '/crib_delivery' => 'crib_part_reports#crib_delivery', :as => "crib_delivery"

  resources :kit_receiving do
    get 'create_filling_show', :on => :member
    post 'kit_filling_edit', :on => :member
    get 'kit_filling_edit', :on => :member
    get 'kit_fill_edit', :on => :member
    post 'pick_ticket_print', :on => :collection
    get 'pick_ticket_print', :on => :collection
    get 'fill_all_cups', :on => :member
    post 'toggle_data',:on => :member
  end

  resources :kit_work_orders do
    get 'work_order_fillings', :on => :collection
    get 'update_due_date', :on => :member
    # get 'part_receiving', :on => :collection
    # post 'receive_parts', :on => :collection
  end

  resources :customers do
    member do
      get "use_default"
    end
  end

  resources :crib_part_requests ,:only=> [:index,:new,:create] do
    collection do
      get "history"
      get "report"
      get "ship_crib_part_list"
      post "ship_crib_part"
      post "print"
      get "get_kit_part_numbers"
      get "populate_kit_details"
      get "get_binloc"
      get "validate_part_no"
    end
  end
  # get "crib_part_requests", to: "crib_part_requests#index"
  # match "/crib_part_requests/new" => "crib_part_requests#new", :as => "new_crib_part_requests"
  # match "/crib_part_requests/history" => "crib_part_requests#history", :as => "history_crib_part_requests"
  # match "/crib_part_requests/report" => "crib_part_requests#report", :as => "report_crib_part_requests"

  match "kit_work_orders/print"  => "kit_work_orders#print"
  match "/part_receiving/"  => "kit_work_orders#part_receiving"
  post "/receive_parts/"  => "kit_work_orders#receive_parts"
  #match ':controller(/:action(/:id))(.:format)'
  resources :kit_delivery, :only => [:index] do
    collection do
      post 'process_deliveries'
    end
  end
end
