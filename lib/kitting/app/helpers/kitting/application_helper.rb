module Kitting
  module ApplicationHelper
    def image_seperator
      "<hr/>".html_safe
    end

    def spinner_tag id
      #Assuming spinner image is called "spinner.gif"
      image_tag("spinner.gif", :id => id, :alt => "Loading....", :style => "display:none")
    end

    def excel_icon(status)
      case status
        when "UPLOADING"
          "excel_uploading.jpg"
        when "PROCESSING"
          "excel_processing.jpg"
        when "COMPLETED"
          "excel_icon_download.png"
        when "UPLOADED"
          "csv_uploaded.png"
        else
          "excel_corrupted.gif"
      end
    end

    def flash_class(level)
      case level
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-danger"
        when :alert then "alert alert-danger"
      end
    end

    def pdf_image_tag(image, options = {})
      options[:src] = File.expand_path("#{Rails.root}/") + image
      tag(:img, options)
    end
    def assign_urls url

      case url
        when 'RMA', 'RMA Request'
          main_app.rma_index_path
        when 'ORDER REQUEST'
          'javascript:void(0);'
        when 'FILE TRANSFER STATUS'
          main_app.file_transfer_status_path
        when 'View Cert: Stk Transfer'
          main_app.index_stock_certs_path(:certs_type => "StockCerts")
        when 'View Certification'
          main_app.certs_path
        when 'Open Order Status'
          main_app.open_orders_path
        when 'Kitting'
          'javascript:void(0);'
        when 'CRIB PART REQUEST'
          'javascript:void(0);'
        when 'Reports'
          main_app.reports_path
        when 'BIN LOCATOR'
          main_app.bin_line_station_index_path
        when 'Critical & Watch'
          main_app.critical_watch_index_path
        when 'Engineering Check'
          main_app.engineering_check_index_path
        when 'STOCK REQUEST'
          main_app.panstock_requests_path
        when 'Supersedence'
          main_app.supersedence_index_path
        when 'Floor View'
          main_app.floor_views_path
        when 'QC LAB'
          main_app.qc_laboratory_index_path
        when 'PN Cross Reference'
          main_app.pn_cross_references_path
        when 'REFILL ORDER STATUS'
          main_app.order_refill_index_path
        when 'Min/Max Report'
          main_app.min_max_reports_path
        when 'Stock Lookup'
          main_app.stock_lookup_index_path
        when "Sikorsky Web Order"
          main_app.web_order_request_index_path(:web_order_type => "Sikorsky")
        when "Variable Quantity Bin Order"
          main_app.web_order_request_index_path
        when "Vendor Barcode"
          '#'
        when "Remote Inventory"
          main_app.remote_inventory_index_path
        else
          '#'
      end
    end

    def assign_sub_menus(main_menu,user_level)
      sub_menu_list = Hash.new
      user_level = user_level.to_i

      if main_menu == 'Kitting'
        customer = get_customer_list(current_user)
        if customer.first.kitting_type == "AD HOC"
          if user_level == 1
            sub_menu_list = []
          elsif user_level == 2 || user_level == 3
            sub_menu_list = {"sub_menu" => [kitting.reports_path], "sub_menu_text" => ["Reports"]}
          elsif user_level == 4
            sub_menu_list = {"sub_menu" => [kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path, kitting.cardex_kits_path, kitting.reports_path], "sub_menu_text" => ["Work Order", "Work Order Processing", "Work Order Receiving" ,  "Cardex Kit Templates", "Reports"]}
          elsif user_level == 5
            sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path, kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration","Work Order", "Work Order Processing", "Work Order Receiving", "Cardex Kit Templates","Reports"]}
          elsif user_level > 5
            sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path,  kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration", "Work Order", "Work Order Processing", "Work Order Receiving", "Cardex Kit Templates","Reports"]}
          else
            sub_menu_list = []
          end
        else
          if user_level == 1
            sub_menu_list = {"sub_menu" => [kitting.kits_path], "sub_menu_text" => ["Kits Setup"] }
          elsif user_level == 2 || user_level == 3
            sub_menu_list = {"sub_menu" => [kitting.kits_path, kitting.reports_path], "sub_menu_text" => ["Kits Setup","Reports"]}
          elsif user_level == 4
            sub_menu_list = {"sub_menu" => [kitting.kits_path, kitting.kit_receiving_index_path, kitting.kit_copies_path,kitting.cardex_kits_path, kitting.reports_path], "sub_menu_text" => ["Kits Setup", "Kit Receiving", "Kit Processing","Cardex Kit Templates", "Reports"]}
          elsif user_level == 5
            sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kits_path, kitting.kits_approval_kits_path, kitting.kit_receiving_index_path, kitting.kit_copies_path, kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration","Kits Setup","Kit Approval","Kit Receiving","Kit Processing","Cardex Kit Templates","Reports"]}
          elsif user_level > 5
            sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kits_path, kitting.kits_approval_kits_path, kitting.kit_receiving_index_path, kitting.kit_copies_path, kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration","Kits Setup","Kit Approval","Kit Receiving","Kit Processing","Cardex Kit Templates","Reports"]}
          else
            sub_menu_list = []
          end
        end

      elsif main_menu == 'ORDER REQUEST'
        if user_level == 1
          sub_menu_list = {"sub_menu" => [main_app.agusta_path], "sub_menu_text" => [ I18n.translate('agusta.create')] }
        else
          sub_menu_list = {"sub_menu" => [main_app.agusta_path, main_app.agusta_inquiry_path, main_app.agusta_reports_path], "sub_menu_text" => [I18n.translate('agusta.create'),I18n.translate('agusta.inquiry'),I18n.translate('agusta.reports')] }
        end

      elsif main_menu == "CRIB PART REQUEST"
        if user_level == 1
          sub_menu_list = []
        elsif user_level == 2 || user_level == 3
          sub_menu_list = {"sub_menu" => [kitting.new_crib_part_request_path, kitting.crib_part_requests_path, kitting.history_crib_part_requests_path, kitting.crib_part_reports_path], "sub_menu_text" => ["Create Request", "Request Processing", "Request History", "Reports"]}
        elsif user_level == 4
          sub_menu_list = {"sub_menu" => [kitting.new_crib_part_request_path, kitting.crib_part_requests_path, kitting.history_crib_part_requests_path, kitting.crib_part_reports_path], "sub_menu_text" => ["Create Request", "Request Processing", "Request History", "Reports"]}
        elsif user_level == 5
          sub_menu_list = {"sub_menu" => [kitting.new_crib_part_request_path, kitting.crib_part_requests_path, kitting.history_crib_part_requests_path, kitting.crib_part_reports_path], "sub_menu_text" => ["Create Request", "Request Processing", "Request History", "Reports"]}
        elsif user_level > 5
          sub_menu_list = {"sub_menu" => [kitting.new_crib_part_request_path, kitting.crib_part_requests_path, kitting.history_crib_part_requests_path, kitting.crib_part_reports_path], "sub_menu_text" => ["Create Request", "Request Processing", "Request History", "Reports"]}
        else
          sub_menu_list = []
        end

      else
        sub_menu_list = []
      end

    end


    def get_customer_list(acc)
      @customer = Kitting::CustomerConfigurations.where(:cust_no => acc)
    end

    def add_class_and_id_to_gridster kit_media_type_name,i
      case kit_media_type_name
        when "Small Removable Cup TB"
          " id=small_yellow_kit class=gridster"
        when "Large Removable Cup TB"
          "id='demo-#{i + 1}' class='gridster gridster_screen_3_#{i}'".html_safe
        when  "Small Configurable TB"
          " id='demo-#{i + 1}' class='gridster sml_orange_#{i + 1}'".html_safe
        when "Large Configurable TB"
          " id= class="
        else
          ""
      end
    end

    def add_class_and_id_to_print_template kit_media_type_name,i
      case kit_media_type_name
        when "Small Removable Cup TB"
          " id=small_yellow_kit class=gridster"
        when "Large Removable Cup TB"
          "id='part-#{i + 1}' class='gridster gridster_part_3_#{i}'".html_safe
        when  "Small Configurable TB"
          " id='demo-#{i + 1}' class='gridster sml_orange_#{i + 1}'".html_safe
        when "Large Configurable TB"
          " id= class="
        else
          ""
      end
    end

    def display_kit_handle kit_media_type_name
      case kit_media_type_name
        when "Small Removable Cup TB"
          "<div class='small_kit_handle'><div class='small_kit_handle_top'></div><div class='small_kit_handle_left'></div><div class='small_kit_handle_bottom'></div><div class='small_kit_handle_right'></div></div>".html_safe
        when "Large Removable Cup TB"
          "<div class='kit_handle'><div class='kit_handle_top'></div><div class='kit_handle_left'></div><div class='kit_handle_bottom'></div><div class='kit_handle_right'></div></div>".html_safe
        when  "Small Configurable TB"
          "<div class='s_o_k_handle'><div class='s_o_k_handle_top'></div><div class='s_o_k_handle_left'></div><div class='s_o_k_handle_bottom'></div><div class='s_o_k_handle_right'></div></div>".html_safe
        when "Large Configurable TB"
          "<div class='kit_handle'><div class='kit_handle_top'></div><div class='kit_handle_left'></div><div class='kit_handle_bottom'></div><div class='kit_handle_right'></div></div>".html_safe
        else
          ""
      end
    end

    def create_group cups, kit_media_type
      whole_group = Array.new
      group_one = Array.new
      group_two = Array.new
      group_three = Array.new
      cups.each do |cup|
        if cup.cup_dimension
          group_id = cup.cup_dimension.split(',')[4].to_i

          if group_id == 1
            group_one << cup
          elsif group_id == 2
            group_two << cup
          elsif group_id == 3
            group_three << cup
          end
        end
      end

      if kit_media_type == "Small Removable Cup TB"
        whole_group << group_one if group_one.size > 0
        whole_group << group_two if group_two.size > 0
        whole_group << group_three if group_three.size > 0

      else
        whole_group << group_one
        whole_group << group_two
        whole_group << group_three
      end

      whole_group
    end
  end
end
