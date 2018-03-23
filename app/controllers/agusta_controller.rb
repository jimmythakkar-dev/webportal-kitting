class AgustaController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only => [:download_excel, :download]
  before_filter :fill_search_list, :only => [:agusta_inquiry]
  # Lists Aircraft ID, Station and Discharge Point for Creating Orders
  def index
    @aircraft_kits_response = AgustaAircraftDetail.find(:all,:select =>"aircraft_id",:conditions => ["customer_number = ?",session[:customer_number]])
    @aircraft_kits_response = @aircraft_kits_response.present? ? @aircraft_kits_response.map(&:aircraft_id).reject(&:blank?) : []
    @kit_part_nos           = []
    @aircraftId             = @aircraft_kits_response.present? ? @aircraft_kits_response.sort! : []
    @stations               = AgustaStation.select(:name).where("station_type IN (?) and customer_number = ? ", "STATION",session[:customer_number] )
    @stations               = @stations.present? ? @stations.map(&:name).sort : []
    @delivery_points        = AgustaStation.select(:name).where("station_type IN (?) and customer_number = ? ", "DELIVERY_POINT",session[:customer_number] )
    @delivery_points        = @delivery_points.present? ? @delivery_points.map(&:name).sort : []
    flash.now[:alert]       = "#{t('agusta.errors.no_data_found')}" if @aircraftId.blank? || @stations.blank? || @delivery_points.blank?
  end
  # Inquiry Search Page for Agusta Users
  def agusta_inquiry
    if can?(:>=, "2")

    else
      redirect_to unauthorized_url
    end
  end
  # Invokes web service with Users enetered criteria to Cardex to Get the Result
  def inquiry_search
    params[:page] = params[:page].nil? ? 1 : params[:page]
    time = (Time.now + 1.day).beginning_of_day
    from_date = ( time - params[:date_range].to_i.days).strftime("%m/%d/%Y") rescue ""
    to_date = Time.now.strftime("%m/%d/%Y") rescue ""
    # Search parameter -------------
    input_data = {
        custNo: session[:customer_number],
        searchBy: params[:search_by_select_value],
        searchVal: params[:search_val],
        ordFromDate: from_date,
        ordToDate: to_date,
        createdBy: params[:user_name],
        inOrderStatus: params[:order_status],
        orderInputSource: params[:order_source],
        page: params[:page].to_s,
        lpp: "100"
    }
    # Search parameter -------------
    @inquiry_search_details = invoke_webservice method: 'post', action: 'orderInquiry', data: input_data
    if @inquiry_search_details
      if ( @inquiry_search_details["errCode"] == "" || @inquiry_search_details["errMsg"]== "" )
        inquiry_details_present = 0
        @inquiry_search_details["errorMsgList"].each do |err|
          inquiry_details_present = inquiry_details_present + 1 if err.blank?
        end
        @inquiry_search_details["errCode"] = inquiry_details_present == 0 ? t('agusta.no_orders') : @inquiry_search_details
        if @inquiry_search_details["errMsg"].blank?
          @totalpage = @inquiry_search_details["totalPageCount"].to_i
          @totalrecord = @inquiry_search_details["totalLineCount"].to_i
          @result = Array.new(@totalrecord*@totalpage).paginate(params[:page],100)
        end
      else
        @inquiry_search_details = t(@inquiry_search_details["errMsg"], :scope => 'agusta.errors', :default => @inquiry_search_details["errMsg"])
      end
    else
      @inquiry_search_details = t('rma.error.service_unavailable')
    end
    fill_search_list
  end
  # Downloads Search Result Excel sheet with all records to End User
  def download_excel

    workbook = WriteExcel.new("#{Rails.public_path}/excel/agusta_inquiry/agusta_inquiry_details.xls")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_bold
    format.set_color('black')
    format.set_align('left')
    format.set_font('Trebuchet MS')
    format.set_size(11)
    time = (Time.now + 1.day).beginning_of_day
    from_date = ( time - params[:date_range].to_i.days).strftime("%m/%d/%Y") rescue ""
    to_date = Time.now.strftime("%m/%d/%Y") rescue ""

    input_data = {
        custNo: session[:customer_number],
        searchBy: params[:search_by_select_value],
        searchVal: params[:search_val],
        ordFromDate: from_date,
        ordToDate: to_date,
        createdBy: params[:user_name],
        inOrderStatus: params[:order_status],
        orderInputSource: params[:order_source],
        page: "",
        lpp: ""
    }

    @inquiry_details = invoke_webservice method: 'post', action: 'orderInquiry', data: input_data
    @row_value = 0
    # create a table in xls file
    worksheet.set_column(0, 1, 20)
    worksheet.set_column(0, 2, 20)
    worksheet.set_column(0, 3, 20)
    worksheet.set_column(0, 4, 20)
    worksheet.set_column(0, 6, 20)
    worksheet.set_column(0, 7, 20)
    worksheet.set_column(0, 8, 20)
    worksheet.set_column(0, 9, 20)
    worksheet.set_column(0, 10, 20)
    worksheet.set_column(0, 11, 20)
    worksheet.set_column(0, 12, 20)
    worksheet.set_column(0, 13, 20)
    worksheet.set_column(0, 16, 20)
    worksheet.set_column(0, 17, 20)
    worksheet.set_column(0, 18, 20)
    worksheet.set_column(0, 19, 20)
    worksheet.set_column(0, 20, 20)
    worksheet.set_column(0, 21, 20)
    worksheet.set_column(0, 22, 20)
    worksheet.set_column(0, 23, 20)
    worksheet.set_column(0, 24, 20)
    worksheet.set_column(0, 25, 20)

    worksheet.write(@row_value+1, 0, I18n.translate('agusta.customer_name'), format)
    worksheet.set_column(@row_value, 0, 40)
    worksheet.write(@row_value+1, 1, I18n.translate('agusta.be_order'), format)
    worksheet.write(@row_value+1, 2, I18n.translate('agusta.order_line'), format)
    worksheet.write(@row_value+1, 3, I18n.translate('agusta.parent_part_number'), format)
    worksheet.write(@row_value+1, 4, I18n.translate('agusta.part_number'), format)
    worksheet.write(@row_value+1, 5, I18n.translate('agusta.customer_part_number'), format)
    worksheet.set_column(5, 0, 30)
    worksheet.write(@row_value+1, 6, I18n.translate('agusta.order_status'), format)
    worksheet.write(@row_value+1, 7, I18n.translate('agusta.order_qty'), format)
    worksheet.write(@row_value+1, 8, I18n.translate('agusta.ship_status'), format)
    worksheet.write(@row_value+1, 9, I18n.translate('agusta.ship_qty'), format)
    worksheet.write(@row_value+1, 10, I18n.translate('agusta.ship_date'), format)
    worksheet.write(@row_value+1, 11, I18n.translate('agusta.ship_time'), format)
    worksheet.write(@row_value+1, 12, I18n.translate('agusta.carrier_name'), format)
    worksheet.write(@row_value+1, 13, I18n.translate('agusta.customer_order'), format)
    worksheet.write(@row_value+1, 14, I18n.translate('agusta.customer_order_line'), format)
    worksheet.set_column(14, 0, 30)
    worksheet.write(@row_value+1, 15, I18n.translate('agusta.build_assembly_program'), format)
    worksheet.set_column(15, 0, 30)
    worksheet.write(@row_value+1, 16, I18n.translate('agusta.station'), format)
    worksheet.write(@row_value+1, 17, I18n.translate('agusta.date_required'), format)
    worksheet.write(@row_value+1, 18, I18n.translate('agusta.time_required'), format)
    worksheet.write(@row_value+1, 19, I18n.translate('agusta.order_date'), format)
    worksheet.write(@row_value+1, 20, I18n.translate('agusta.order_time'), format)
    worksheet.write(@row_value+1, 21, I18n.translate('agusta.requester'), format)
    worksheet.write(@row_value+1, 22, I18n.translate('agusta.operation'), format)
    worksheet.write(@row_value+1, 23, I18n.translate('agusta.reason'), format)
    worksheet.write(@row_value+1, 24,I18n.translate('agusta.remarks'), format)
    worksheet.write(@row_value+1, 25,I18n.translate('agusta.scan_code'), format)

    (0..@inquiry_details["kitPartNo"].length-1).each do |i|
      worksheet.write(@row_value+2+i, 0, @inquiry_details["custName"][i])
      worksheet.write(@row_value+2+i, 1, @inquiry_details["requestIdList"][i])
      worksheet.write(@row_value+2+i, 2, @inquiry_details["orderNoList"][i])
      worksheet.write(@row_value+2+i, 3, @inquiry_details["kitPartNo"][i])
      worksheet.write(@row_value+2+i, 4, @inquiry_details["primePns"][i])
      worksheet.write(@row_value+2+i, 5, @inquiry_details["custRefPns"][i])
      worksheet.write(@row_value+2+i, 6, @inquiry_details["orderStatus"][i])
      worksheet.write(@row_value+2+i, 7, @inquiry_details["pnOrderQty"][i])
      worksheet.write(@row_value+2+i, 8, @inquiry_details["pnShipStatus"][i])
      worksheet.write(@row_value+2+i, 9, @inquiry_details["pnShipQtys"][i])
      worksheet.write(@row_value+2+i, 10, @inquiry_details["shipDate"][i])
      worksheet.write(@row_value+2+i, 11, @inquiry_details["shipTime"][i])
      worksheet.write(@row_value+2+i, 12, @inquiry_details["carrierName"][i])
      worksheet.write(@row_value+2+i, 13, "")
      worksheet.write(@row_value+2+i, 14, "")
      worksheet.write(@row_value+2+i, 15, @inquiry_details["assembly"][i])
      worksheet.write(@row_value+2+i, 16, @inquiry_details["stations"][i])
      worksheet.write(@row_value+2+i, 17, @inquiry_details["requiredDate"][i])
      worksheet.write(@row_value+6+i, 18, @inquiry_details["requiredTime"][i])
      worksheet.write(@row_value+2+i, 19, @inquiry_details["orderDate"][i])
      worksheet.write(@row_value+2+i, 20, @inquiry_details["orderTime"][i])
      worksheet.write(@row_value+2+i, 21, @inquiry_details["requester"][i])
      worksheet.write(@row_value+2+i, 22, @inquiry_details["operation"][i])
      worksheet.write(@row_value+2+i, 23, @inquiry_details["reason"][i])
      worksheet.write(@row_value+2+i,24,((@inquiry_details["note"][i].present? ? @inquiry_details["note"][i] : "" ) if @inquiry_details["note"].present?))
      worksheet.write(@row_value+2+i,25,((@inquiry_details["deliveryScanCode"][i].present? ? @inquiry_details["deliveryScanCode"][i] : "N/A" ) if @inquiry_details["deliveryScanCode"].present?))
    end
    workbook.close
    send_file "#{Rails.public_path}/excel/agusta_inquiry/agusta_inquiry_details.xls", :disposition => "attachment"
  end
  # Creates Order Using Ajax Request [Creates Duplicate Order On Demand from User]
  def send_orders

    if request.xhr?
      params[:kit_part_nos].upcase! if params[:kit_part_nos].present?
      # code for calling CreateKit RBO
      if params[:new_kit_flag].present?
        kit_parts = []; new_kit_part_qtys = []
        params["AgustaOrderQtyReadOnly"].each_with_index do |qty, index|
          new_kit_part_qtys << params["AgustaOrderQtyReadOnly"][index]
          kit_parts <<  params["part_number"][index]
        end
        new_kit_data_hash = { custNo: session[:customer_number], aircraftId: params[:aircraftId], kitPartNo: params[:kit_part_nos],
                              kitComponents: kit_parts, kitCompQtys: new_kit_part_qtys }
        @response_kit_submit = invoke_webservice method: 'post', action: 'createKit', data: new_kit_data_hash
        if @response_kit_submit.present?
          if @response_kit_submit["errMsg"].present?
            @new_kit_error =  @response_kit_submit["errMsg"]
          else
            aircraftId = @response_kit_submit["aircraftId"]
            new_kit_part_number = @response_kit_submit["kitPartNo"]
            if aircraftId.present? && new_kit_part_number
              air_craft_details  = AgustaAircraftDetail.where(:aircraft_id => aircraftId, :customer_number => current_customer.cust_no )
              if air_craft_details.present?
                kit_part_nums = air_craft_details.first.kit_part_numbers
                if kit_part_nums.present?
                  kit_parts_arr = kit_part_nums.split(",")
                  kit_parts_arr.insert(0,new_kit_part_number) unless kit_parts_arr.include?(new_kit_part_number)
                  updated_kit_nums = kit_parts_arr.join(",")
                  air_craft_details.first.update_attribute('kit_part_numbers' , updated_kit_nums)
                end
              end
            end
            @new_kit_success =  I18n.t('bom_success_message',:scope => "agusta")
          end
        end
      end

      ################ START CODE FOR SEND ORDERS USING AJAX REQUEST ############
      if params["AgustaOrderQty"].present?
        @kit_components_details = []; @kit_comp_qtys_details = []; @reason_codes_details = [];@notes_details = [];@kit_part_no = [];@kit_part_no << params[:kit_part_nos];qty_present = 0
        params[:motive].map! { |x| (x == "Select" ||x == "Selezionare") ? "" : x }
        params["AgustaOrderQty"].each_with_index do |qty, index|
          if qty.to_i >= 1
            qty_present += 1; @kit_components_details << params["part_number"][index]; @kit_comp_qtys_details << params["AgustaOrderQty"][index]; @reason_codes_details << params["motive"][index];@notes_details << params["PartComment"][index]
          end
        end
        if qty_present > 0
          params[:agusta_order_select] ||= params[:agusta_order_select_floor]
          allow_duplicate_orders = params[:duplicateOrder].present? ?  "1" : "0"
          if params[:agusta_order_select] == I18n.t('select',:scope => "agusta")
            order_type = ""
          else
            order_type = params[:agusta_order_select] == I18n.t("expedited_order",:scope => "agusta._kit_components_details") ? "WEBDR" : "WEBEORDER"
          end
          data_hash = { custNo: session[:customer_number], aircraftId: params[:aircraftId], kitPartNo: @kit_part_no, station: params[:stations], deliveryPoint: params[:delivery_points], kitComponents: @kit_components_details, kitCompQtys: @kit_comp_qtys_details, reasonCodes: @reason_codes_details, notes: @notes_details, orderType: order_type, userId: session[:user_name], localTime: params[:localTime], allowDup: allow_duplicate_orders }
          @response_order_submit = invoke_webservice method: 'post', action: 'webOrder', data: data_hash
          if @response_order_submit.present?
            if @response_order_submit["errCode"].blank? && @response_order_submit["errMsg"].reject(&:blank?).empty? && @response_order_submit["orderNumber"].present?
              @orders_details = { :order_number => @response_order_submit["orderNumber"],:order_type => order_type,:customer_name => session[:customer_Name],:customer_number => session[:customer_number],:project_id => params[:aircraftId],:station_name => params[:stations],:discharge_point_name => params[:delivery_points],:kit_part_number => @kit_part_no.join(""),:created_by => session[:user_name] }
              @orders = Order.new(@orders_details)
              if @orders.save
                @kit_comp_qtys_details.each_with_index do |qty, index|
                  @orders.order_part_details.create( :part_number => @kit_components_details[index],:quantity => @kit_comp_qtys_details[index],:reason_code => @reason_codes_details[index],:note => @notes_details[index] )
                end
                @success = I18n.t("agusta.agusta_creation_msg",:order_no => @response_order_submit["orderNumber"])
                #flash[:success] = I18n.t("agusta.agusta_creation_msg",:order_no => @response_order_submit["orderNumber"])
                #redirect_to agusta_path
              else
                @response_order_submit["errMsg"].reject!(&:blank?)
                @error = @response_order_submit["errMsg"].join("<br/>").html_safe
                @error = check_cardex(@error)
                #flash[:alert] = @response_order_submit["errMsg"].join("<br/>").html_safe
                #redirect_to agusta_path
              end
            else
              @response_order_submit["errMsg"].reject!(&:blank?)
              if @response_order_submit["errCode"] == "11"
                @response_order_submit["errMsg"].each_with_index do |data,index|
                  part_number = @response_order_submit["errMsg"][index].split(" ")[1]
                  order_qty =  @response_order_submit["errMsg"][index].split(" ")[4]
                  order_number = @response_order_submit["errMsg"][index].split(" ")[9]
                  @response_order_submit["errMsg"][index] = I18n.translate("duplicate_part_order",:scope => "agusta.errors",:part_number => part_number,:qty_ordered => order_qty,:order_number => order_number,:default => @response_order_submit["errMsg"][index] )
                end
                @error = @response_order_submit["errMsg"].join("<br/>").html_safe
                @error = check_cardex(@error)
              else
                @error = @response_order_submit["errMsg"].join("<br/>").html_safe
                @error = check_cardex(@error)
              end
            end
          else
            @error = I18n.t("server_error",:scope => "agusta" )
          end
        else
          @error = t("agusta.params_missing_qty")
        end
      else
        @error = "#{t('agusta.params_missing_msg')}"
      end
    else
      request_format = request.format
      config.logger.error request.inspect
      flash[:error] = "Your Order Request Cannot be Processed as the request format is of type #{request_format}. Contact your KLX Administrator."
      redirect_to agusta_path
    end
    ################ START CODE FOR SEND ORDERS USING AJAX REQUEST ############
  end
  #  Validates KIT PART DETAILS whether or not in Contract
  def get_kit_part_details
    if params[:additional_part].present?
      @kit_parts_details = kit_part_list
    else
      if !params[:aircraft_id].blank? && !params[:kit_part_no].blank?
        if params[:new_kit_flag].present?
          @kit_parts_details = nil
        else
          @kit_parts_details = kit_part_list
          if @kit_parts_details["kitComponents"].present?
            if @kit_parts_details["kitComponents"].reject(&:blank?).blank?
              params[:new_kit_flag] = "true"
            end
          end
        end
      else
        @kit_parts_details = nil
      end
    end
  end
  # Lists out Kit Part Numbers depending on Aircraft Id Selected by User
  def get_kit_details
    ################ START CODE FOR GET P/N Kit FROM DATABASE USING AJAX REQUEST ############
    if params[:aircraft_id].present?
      @aircraft_kits_details = AgustaAircraftDetail.find(:first,:select =>"kit_part_numbers",:conditions => ["aircraft_id = ? and customer_number = ? ", params[:aircraft_id],session[:customer_number]])
      @kit_part_nos = @aircraft_kits_details.kit_part_numbers.present? ? @aircraft_kits_details.kit_part_numbers.split(/,/).sort : nil
    else
      flash.now[:alert] = "#{t('rma.error.service_unavailable')}" if @kit_part_nos.blank?
    end
    render :json => { :browser => (browser.ie8? || browser.ie6? || browser.ie7?) ,:kit_part_nos=>@kit_part_nos }
  end
  # Validates Contract Check and Internationalize Error Message coming from Cardex
  def get_contract_stock_check
    @contractCheck = params["contractChec"].present? ? "1" : "0"
    @contract_stock_check_details = contract_stock_check
    if @contract_stock_check_details
      unless @contract_stock_check_details["errMsg"].first.blank?
        if @contract_stock_check_details["errMsg"].first.include?("Quantity ordered #{params[:AgustaorderQty]} is greater than Total available quantity")
          @contract_stock_check_details["errMsg"] = I18n.translate("quantity_greater",:available_quantity =>@contract_stock_check_details["errMsg"].first.split().last, :ordered_quantity =>params[:AgustaorderQty] ,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"].first)
        elsif @contract_stock_check_details["errMsg"].first.include? "Stock is available only in bailment is"
          @contract_stock_check_details["errMsg"] = I18n.translate("available_stock_msg",:available_stock =>@contract_stock_check_details["errMsg"].first.split().last,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"].first)
        elsif @contract_stock_check_details["errMsg"].length > 1
          @numbers_array = @contract_stock_check_details["errMsg"].second.present? ? @contract_stock_check_details["errMsg"].second.scan( /\d+/ ) : ""
          whse = @numbers_array.first.present? ? @numbers_array.first : 0
          stock_available = @numbers_array.second.present? ? @numbers_array.second : 0
          if @contract_stock_check_details["errMsg"].any? { |s| s.include?('Total stock in bailment and warehouse(s) is ') } && @contract_stock_check_details["errMsg"].any? { |s| s.include?('Total Stock available in bailment is ') }
            @stock_available_bailment_array = @contract_stock_check_details["errMsg"][3].present? ? @contract_stock_check_details["errMsg"][3].scan( /\d+/ ) : ""
            @stock_available_bailment_warehouse_array = @contract_stock_check_details["errMsg"][4].present? ? @contract_stock_check_details["errMsg"][4].scan( /\d+/ ) : ""
            stock_available_bailment = @stock_available_bailment_array.first.present? ? @stock_available_bailment_array.first : 0
            stock_available_bailment_warehouse = @stock_available_bailment_warehouse_array.first.present? ? @stock_available_bailment_warehouse_array.first : 0
            @contract_stock_check_details["errMsg"] = @contract_stock_check_details["errMsg"].join("<br />")
            @contract_stock_check_details["errMsg"] = I18n.translate("partial_stock_total",:available_stock => stock_available,:whse => whse,:stock_available_bailment => stock_available_bailment,:stock_available_bailment_warehouse => stock_available_bailment_warehouse,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"]).html_safe
          elsif @contract_stock_check_details["errMsg"].any? { |s| s.include?('Total Stock available in bailment is ') }
            @stock_available_bailment_array = @contract_stock_check_details["errMsg"][3].present? ? @contract_stock_check_details["errMsg"][3].scan( /\d+/ ) : ""
            stock_available_bailment = @stock_available_bailment_array.first.present? ? @stock_available_bailment_array.first : 0
            @contract_stock_check_details["errMsg"] = @contract_stock_check_details["errMsg"].join("<br />")
            @contract_stock_check_details["errMsg"] = I18n.translate("partial_stock_total_bailment_only",:available_stock => stock_available,:whse => whse,:stock_available_bailment => stock_available_bailment,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"]).html_safe
          elsif @contract_stock_check_details["errMsg"].any? { |s| s.include?('Total stock in bailment and warehouse(s) is ') }
            @stock_available_bailment_warehouse_array = @contract_stock_check_details["errMsg"][3].present? ? @contract_stock_check_details["errMsg"][3].scan( /\d+/ ) : ""
            stock_available_bailment_warehouse = @stock_available_bailment_warehouse_array.first.present? ? @stock_available_bailment_warehouse_array.first : 0
            @contract_stock_check_details["errMsg"] = @contract_stock_check_details["errMsg"].join("<br />")
            @contract_stock_check_details["errMsg"] = I18n.translate("partial_stock_bailment_warehouse",:available_stock => stock_available,:whse => whse,:stock_available_bailment_warehouse => stock_available_bailment_warehouse,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"]).html_safe
          else
            @contract_stock_check_details["errMsg"] = @contract_stock_check_details["errMsg"].join("<br />")
            @contract_stock_check_details["errMsg"] = I18n.translate("partial_stock",:available_stock => stock_available,:whse => whse,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"]).html_safe
          end
        else
          translated_message = @contract_stock_check_details["errMsg"].include?("Requested part is not available in your on site FSL. Process stock request anyway?") ? "process_request" : @contract_stock_check_details["errMsg"].first
          @contract_stock_check_details["errMsg"] = I18n.t(translated_message,:scope => "agusta.errors",:default => @contract_stock_check_details["errMsg"] )  if @contract_stock_check_details["errMsg"].present?
        end
      end
    else
      @contract_stock_check_details = nil
    end
    render json: @contract_stock_check_details
  end
  #  Displays Agusta Reports on WEB.
  def reports
    if can?(:>=, "2")
      @directory_path = APP_CONFIG['agusta_report_path']
      #@filter_name = current_user + "*.*"
      reports = AGUSTA_REPORTS.join(",")
      @filter_name = current_user + "{#{reports}}"
      if @directory_path.present?
        if Report.directory_exists?(@directory_path)
          @files = Dir.glob("#{@directory_path}#{@filter_name}")
          @files = @files.sort do |a, b|
            a.upcase <=> b.upcase
          end
        else
          flash.now[:notice] = I18n.translate("directory_doesnot_exist", :scope => "reports.index")
        end
      else
        flash.now[:notice] = I18n.translate("directory_doesnot_exist", :scope => "reports.index")
      end
      render :reports
    else
      redirect_to unauthorized_url
    end
  end
  # Downloads the Web Reports for Agusta Users from WEB
  def download
    if can?(:>=, "2")
      if params[:file]
        @directory_path = APP_CONFIG['agusta_report_path']
        @file_name = params[:file]
      elsif params[:report]
        @directory_path = APP_CONFIG['agusta_report_path']
        @file_name = Report.get_file_name(params[:report], current_user)
        @display_name = @file_name.split("_").last
      end
      send_file "#{@directory_path}#{@file_name}", :filename => @display_name, :disposition => "attachment"
    else
      redirect_to unauthorized_url
    end
  end
  #  Adds Addition kit Part Number to Requesting Order
  def add_part
    @kit_component = params[:partNo]
    @contractCheck = "1"
    @contract_stock_check_details = contract_stock_check
  end

  private

  def kit_part_list
    invoke_webservice method: 'get', action: 'bomParts', query_string: {custNo: session[:customer_number], aircraftId: params["aircraft_id"], kitPartNo: params["kit_part_no"]}
  end

  def contract_stock_check
    params["AgustaorderQty"] = params["AgustaorderQty"].present? ? params["AgustaorderQty"] : "0"
    stockCheck = params["partCheck"].present? ? "0" : "1"
    invoke_webservice method: 'get', action: 'contractStockCheck', query_string: {custNo: session[:customer_number],
                                                                                  partNo: params["partNo"],
                                                                                  orderQty: params["AgustaorderQty"],
                                                                                  contractCheck: @contractCheck,
                                                                                  stockCheck: stockCheck
    }
  end

  def check_cardex(error)
    error.blank? ? I18n.t('check_cardex',:scope => "agusta.errors") : error
  end

end
