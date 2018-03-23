module ApplicationHelper
  require 'barby'
  require 'barby/barcode/code_39'
  require 'barby/barcode/code_128'
  require 'barby/outputter/png_outputter'

  def image_seperator
    content_tag :hr
    # image_tag "content_seperatorbig.gif"
  end

  def wicked_pdf_stylesheet_link_tag(*sources)
    sources.collect { |source|
      "<style type='text/css'>#{Rails.application.assets.find_asset("#{source}.css")}</style>"
    }.join("\n").gsub(/url\(['"](.+)['"]\)(.+)/,%[url("#{wicked_pdf_image_location("\\1")}")\\2]).html_safe
  end

  def wicked_pdf_image_location(img)
    "file://#{Rails.root.join('app', 'assets', 'images', img)}"
  end

  def flash_notice
    raw flash[:notice]
  end

  def flash_class(level)
    case level
      when :notice then "alert alert-info"
      when :success then "alert alert-success"
      when :error then "alert alert-danger"
      when :alert then "alert alert-danger"
    end
  end

  def assign_urls session_menu
    url = (session_menu & MENU_ARRAY).first if session_menu.kind_of?Array
    url ||= session_menu

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
      when "CUSTOM KITS"
        'javascript:void(0);'
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
          sub_menu_list = {"sub_menu" => [ kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path, kitting.cardex_kits_path, kitting.reports_path], "sub_menu_text" => ["Work Order", "Work Order Processing", "Work Order Receiving" ,"Cardex Kit Templates", "Reports"]}
        elsif user_level == 5
          sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path, kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration","Work Order", "Work Order Processing", "Work Order Receiving" ,"Cardex Kit Templates","Reports"]}
        elsif user_level > 5
          sub_menu_list = {"sub_menu" => [kitting.admin_index_path, kitting.kit_work_orders_path, kitting.work_order_fillings_kit_work_orders_path, kitting.part_receiving_path, kitting.cardex_kits_path,  kitting.reports_path], "sub_menu_text" => ["Administration", "Work Order", "Work Order Processing", "Work Order Receiving" , "Cardex Kit Templates","Reports"]}
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
    elsif main_menu == "CUSTOM KITS"
      sub_menu_list = {"sub_menu" => [main_app.custom_kits_path,main_app.custom_kit_report_custom_kits_path], "sub_menu_text" => [I18n.translate('agusta.search_status'),I18n.translate('agusta.reports')] }
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

  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path("#{Rails.root}/") + image
    tag(:img, options)
  end

  def generate_barcode part_number
    barcode = Barby::Code39.new(part_number,true)
    File.open(APP_CONFIG['kitting_barcode_path']+part_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
      f.write barcode.to_png(:margin => 3, :xdim => 1, :height => 35)
    }
  end

  def generate_barcode_for_all_in_one kit_number
    barcode = Barby::Code39.new(kit_number)
    File.open(APP_CONFIG['kitting_barcode_path']+kit_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
      f.write barcode.to_png(:margin=>0,:xdim=>2)
    }
  end

  def generate_barcode_for_underscore_part part_number
    barcode = Barby::Code128A.new(part_number)
    File.open(APP_CONFIG['kitting_barcode_path']+part_number.split('').map(&:ord).join("")+'.png', 'w'){|f|
      f.write barcode.to_png(:margin=>0,:xdim=>2)
    }
  end

  def invoke_service url
    query_string = url[:query_string].blank? ? "" : url[:query_string].map{ |key, value|
      "#{key}=#{CGI.escape(value)}" }.join("&").insert(0, "?")
    url[:class] = url[:class].blank? ? "" : url[:class]
    webservice_uri = URI.join(APP_CONFIG['webservice_uri_format'], '/application/',
                              url[:class], url[:action], query_string)
    uri = URI.parse(webservice_uri.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    if APP_CONFIG['webservice_uri_format'].include?("https")
      http.use_ssl = true
      http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
    end
    http.open_timeout = 25
    http.read_timeout = 500
    http.start do |http|
      if url[:method] == 'get'
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new uri.path, initheader = { 'Content-Type' => 'application/json' }
        request.body = url[:data].to_json
      end
      request.basic_auth APP_CONFIG['username'], APP_CONFIG['password']
      response = http.request request
      JSON.parse(response.body) if response.code =~ /^2\d\d$/
    end
  rescue => e
    puts "Error Message is #{e.inspect} #{e.backtrace}"
  end

end
