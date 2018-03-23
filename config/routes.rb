class AuthConstraint
  def matches?(request)
    if !request.session.blank?
      if request.session[:menu_description].present?
        request.session[:menu_description].include?("ORDER REQUEST")? true : false
      else
        false
      end
    else
      false
    end
  end
end

Web::Application.routes.draw do

  # get "file_transfer_status/index"
  resources :file_transfer_status, :only => [:index]
  match "/file_transfer_status/search" => "file_transfer_status#search", :as =>"file_transfer_status_search"
  match "/file_transfer_status/pay_load_detail" => "file_transfer_status#pay_load_detail", :as =>"pay_load_detail"
  match "/file_transfer_status/download_pick_list_excel" => "file_transfer_status#download_pick_list_excel", :as =>"download_pick_list_excel"
  match "/file_transfer_status/download_delivery_list_excel" => "file_transfer_status#download_delivery_list_excel", :as =>"download_delivery_list_excel"

  resources :vendor_barcode, :only => [:index]
  match "/vendor_barcode/search" => "vendor_barcode#search", :as =>"vendor_barcode_search"
  match "/vendor_barcode/qty_form" => "vendor_barcode#qty_form", :as =>"vendor_barcode_qty_form"
  match "/vendor_barcode/confirm_print" => "vendor_barcode#confirm_print", :as =>"confirm_print"
  match "/vendor_barcode/print_barcode" => "vendor_barcode#print_barcode", :as =>"print_barcode"
  match "/vendor_barcode/mfr_search" => "vendor_barcode#mfr_search", :as =>"mfr_search"
  match "/vendor_barcode/mfr_search_result" => "vendor_barcode#mfr_search_result", :as =>"mfr_search_result"
  # The root url of the application or in other terms home page

  constraints(AuthConstraint.new) do
    root :to => "agusta#index"
  end

  root :to => 'open_orders#index'
  match "/agusta/inquiry" => "agusta#agusta_inquiry"
  match "/agusta/reports" => "agusta#reports"
  match "/agusta/generate_report" => "agusta#generate_report"
  match "/agusta/download" => "agusta#download"


  mount Kitting::Engine ,    at: '/kitting'

  get "login", :to => "user_sessions#new", :as => "login"
  post "new_reset_password", :to => "user_sessions#new_reset_password"
  post "reset_password", :to => "user_sessions#reset_password"
  get "logout", :to => "user_sessions#destroy", :as => "logout"
  get "unauthorized", :to => "user_sessions#unauthorized", :as => "unauthorized"
  get "switch_account", :to => "user_sessions#switch_account", :as => "switch_account"

  # Part Cross Reference Routes
  resources :pn_cross_references, :only => [:index] do
    get "search_pn", :on => :collection
  end
  #RMA routes
  resources 'rma' do
    collection do
      get 'create' => "rma#show"
      get '/invoice/search' => "rma#search_invoice"
      get 'invoice/:invoice_num' => 'rma#invoice_details'
      get 'inquiry' => "rma#inquiry"
      get 'show_invoices/:page' => 'rma#paginated_invoices'
      post 'preview' => "rma#preview_rma_request"
      post 'submit' => "rma#submit"
      match 'save_img' => "rma#save_img"
      get 'search' => 'rma#rma_search'
      get 'details/:rma_no' => 'rma#details'
      get 'print_details/:rma_no' => 'rma#print_details'
      post 'send_message' => 'rma#send_message'
      get 'print' => "rma#print"
    end
  end

  resources 'web_order_request', :only=> [:index] do
    collection do
      post "process_form", :action => "process_form"
    end
  end

  #match "/rma/inquiry" => "rma#rma_inquiry"

  resources 'floor_views', except: :show do
    collection do
      get 'history_excel/:days', :action => 'history_excel', :as => 'history_excel'
      get 'location_excel/:location/:page', :action => 'location_excel', :as => 'location_excel'
      get 'search_from_location', :action => 'search_from_location', :as => 'search_from_location'
      get 'search_part_number', :action => 'search_part_number', :as => 'search_part_number'

    end
  end
  get 'floor_views/location_page/:page/:location' => "floor_views#location_page", :as => "location_page"
  get 'floor_views/floor_view_history' => "floor_views#floor_view_history", :as => "floor_view_history"
  get 'floor_views/history_days' => "floor_views#history_days"
  get 'floor_views/sort_location/:v_col/:v_order/:bin_center_part_response' => "floor_views#sort_location"
  post 'floor_views/send_orders' => "floor_views#send_orders"
  get 'floor_views/update_floor_view' => "floor_views#update_floor_view", :as => 'update_floor_views'
  post 'floor_views/form_process' => "floor_views#form_process", :as => 'floor_view_form_process'
  match "/floor_views/print_part_label" => "floor_views#print_part_label"

  resources "panstock_requests" do
    collection do
      get 'get_line_station', :action => 'get_line_station', :as => 'get_line_station'
      post 'form_process', :action => 'form_process', :as => 'form_process'
      post 'send_panstock_changes', :action => 'send_panstock_changes', :as => 'send_panstock_changes'
      get 'panstock_history', :action => 'panstock_history', :as => 'panstock_history'
      get 'panstock_days', :action => 'panstock_days', :as => 'panstock_days'
      get 'panstock_history_excel/:days', :action => 'panstock_history_excel', :as => 'panstock_history_excel'
      get 'action_history', :action => 'action_history', :as => 'action_history'
      get 'bulk_history/iAction', :action => 'bulk_history', :as => 'bulk_history'
      post 'bulk_form_process', :action => 'bulk_form_process', :as => 'bulk_form_process'
      get 'bulk_history_days', :action => 'bulk_history_days', :as => 'bulk_history_days'
      get 'panstock_bulk_history_excel/:days', :action => 'panstock_bulk_history_excel', :as => 'panstock_bulk_history_excel'
      post "validate_contract"
    end
  end

  resources :user_sessions do
    collection do
      get "change_user_lang"
    end
  end

  match "/bin_line_station/search_by_location" => "bin_line_station#search_by_location"
  match "/bin_line_station/search_part_number" => "bin_line_station#search_part_number"
  match "/bin_line_station/print_part_label" => "bin_line_station#print_part_label"
  resources :bin_line_station do
    collection do
      get 'download_excel'
      get  'new_part_to_location'
      post 'create_part_to_location'
      post 'update_line_station'
      #get 'search_by_location'
    end
  end


  resources :open_orders do
    post 'search', :on => :collection
    get 'invoice_display', :on => :member
  end

#  get "/kitting/new_err" =>  "kitting#new_err", :as =>"kitting_new_err"
#  get "/kitting/:id/history" =>  "kitting#history", :as =>"kitting_history"
#  match "/kitting/search" => "kitting#search", :as =>"kitting_search"
#
#  resources :kitting , :constraints => {:id => /.*/}

  resources :engineering_check do
    collection do
      get 'print_label'
    end
  end
  post "/engineering_check/search",:as =>"engineering_check_search"
  get "/engineering_check/search/:id" =>  "engineering_check#search", :id => /.*/, :as =>"search_bin_part"
  get "/engineering_check/:bin_location/:page" => 'engineering_check#download_excel', :as => 'download_excel'


  resources :supersedence do
    post 'search', :on => :collection
  end


  resources :critical_watch do
    get 'view_history', :on => :member
    get 'download', :on => :collection
  end

  resources :reports do
    collection do
      get "generate"
      get "download"
      match "upload", via: [:get,:post]
    end
  end

  resources :min_max_reports
  resources :stock_lookup do
    post 'search', :on => :collection
  end

  resources :certs do
    collection do
      post 'search'
      post 'view_certs'
      post 'search_stock'
      get 'index_stock'
    end
  end

  resources :qc_laboratory do
    get "get_bin_center_parts"
    get "download_excel"
  end
  get "/qc_laboratory/search/:id" =>  "qc_laboratory#search", :id => /.*/, :as =>"qc_laboratory_fuzzy_search"
  post "/qc_laboratory/search",:as =>"qc_laboratory_search"

  resources :order_refill do
    collection do
      get 'search'
    end
  end


  resources "agusta" do
    collection do
      post 'send_order', :action => 'send_panstock_changes', :as => 'send_panstock_changes'
      post 'send' => "agusta#send_orders"
      get 'get_kit_part_details', :action => 'get_kit_part_details', :as => 'get_kit_part_details'
      get 'get_kit_details', :action => 'get_kit_details', :as => 'get_kit_details'
      get 'get_contract_stock_check', :action => 'get_contract_stock_check', :as => 'get_contract_stock_check'
      get "add_part"
      get 'inquiry_search', :action => 'inquiry_search', :as => 'inquiry_search'
      get 'download_excel'
    end
  end
  resources :remote_inventory,:only => [:index] do
    collection do
      post 'search'
      post "search_async"
    end
  end

  resources :custom_kits, :only => [:index] do
    collection do
      post "delivery_report"
      post "download_excel"
      post "search_status"
      get "custom_kit_report"
      get "get_kit_part_numbers"
    end
  end
  match '*a', :to => 'open_orders#routing_error'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
