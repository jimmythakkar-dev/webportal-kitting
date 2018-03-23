class EngineeringCheckController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:download_excel]
  def index
  end
  def search
    @binCenters_response = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: { custNo: current_user }
    if @binCenters_response
    unless @binCenters_response["errMsg"].blank?
      flash.now[:alert]     =  @binCenters_response["errMsg"]
      render 'no_bin_center'
    else
      # PN search from bin center list
      @part_no              = params[:id].blank? ? params["txtPartNo"].try(:strip) : params[:id].try(:strip)
      @partNums_response    = invoke_webservice method: 'get',class: 'custInv/',action: 'partNums', query_string: { custNo: current_user, partNo: @part_no }

      # test getBinParts is not on bin map get prime via getAllPartNums
      # match inv PN, set cust forecast number

      @my_prime_pn        =  @partNums_response["primePNList"] && !@partNums_response["primePNList"].join().blank? ? @partNums_response["primePNList"] : @part_no
      @fc_cust_part_no    = (@partNums_response["invPNList"].include? @part_no) ? @part_no : @partNums_response["invPNList"].first
      @whse_cust_part_no  = (@partNums_response["custPartNoList"].include? @part_no) ? @part_no : @partNums_response["invPNList"].first

      #convert arr value to string

      @prime_pn           = EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]
      @fc_cust_part_no    = EngineeringCheck.get_covert_arr_to_str @fc_cust_part_no
      @whse_prime_part_no = EngineeringCheck.get_covert_arr_to_str @my_prime_pn

      # fuzzy search for part number render fuzzy search page

      if @partNums_response["searchPartList"] && !@partNums_response["searchPartList"].join().blank?
        render 'fuzzy_search'
      else

        @partNums_response["searchPartList"] = @part_no if @partNums_response["searchPartList"] &&
            @partNums_response["searchPartList"].join().blank? && @partNums_response["searchPartList"].blank?

        #unless @partNums_response["errMsg"].blank?
        @my_inv_pn                    = @whse_cust_part_no  =  @part_no
        @whse_prime_part_no           = EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]
        flash.now[:alert]             = @partNums_response["errMsg"]
        @superSedenceSearch_response  = invoke_webservice method: 'get',class: 'custInv/', action: 'superSedenceSearch', query_string: {custNo: current_user, partNo: @my_inv_pn || @part_no }
        #else

        if @partNums_response["custPartNoList"].include? @part_no
          @my_inv_pn          =  @whse_cust_part_no  =  @part_no
          @whse_prime_part_no =  EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]
        elsif @partNums_response["invPNList"].include? @part_no
          my_index            =  @partNums_response["invPNList"].index(@part_no)
          @whse_cust_part_no  =  @my_cust_pn =  @partNums_response["custPartNoList"][my_index]
          @my_inv_pn          =  @partNums_response["invPNList"][my_index]
          @whse_prime_part_no =  EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]
        elsif @partNums_response["primePNList"].include? @part_no
          my_index            =  @partNums_response["primePNList"].index(@part_no)
          @whse_cust_part_no  =  @my_cust_pn =  @partNums_response["custPartNoList"][my_index]
          @my_inv_pn          =  @partNums_response["invPNList"][my_index]
          @whse_prime_part_no =  EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]
        elsif @partNums_response["scancodeList"].include? @part_no
          my_index            =  @partNums_response["scancodeList"].index(@part_no)
          @whse_cust_part_no  =  @my_cust_pn =  @partNums_response["custPartNoList"][my_index]
          @my_inv_pn          =  @partNums_response["invPNList"][my_index]
          @whse_prime_part_no =  EngineeringCheck.get_covert_arr_to_str @partNums_response["primePNList"]

        else
          @superSedenceSearch_response = invoke_webservice method: 'get',class: 'custInv/', action: 'superSedenceSearch', query_string: { custNo: current_user, partNo: @my_inv_pn || @part_no }
          flash.now[:notice]  =  ("#{@part_no} not on Bin Map or Contract. Please contact your KLX representative.<br>" + @superSedenceSearch_response["errMsg"] +"").html_safe
        end

        if @partNums_response["custPartNoList"].blank?
          @response_part_no_list = [""]
        else
          @response_part_no_list = @partNums_response["custPartNoList"].join("").gsub(/[^0-9a-z ]/i, '')
        end

        if @partNums_response["scancodeList"].blank?
          @partNums_response["scancodeList"] = [""]
        end

        #if((@response_part_no_list.include?  @part_no) || (@partNums_response["scancodeList"].include? @part_no))
        #if((@partNums_response["custPartNoList"].include? @part_no) || (@partNums_response["scancodeList"].include? @part_no))
        # method, class, action, custNo, partNo

        @superSedenceSearch_response      = invoke_webservice method: 'get', class: 'custInv/', action: 'superSedenceSearch', query_string: {custNo: current_user, partNo: @my_inv_pn || @part_no }
        @lead_times_response              = invoke_webservice method: 'get', class: 'custInv/', action: 'leadTimes', query_string: { custNo: current_user, custPartNo: @prime_pn }
        @whse_on_hand_qty_response        = invoke_webservice method: 'get', class: 'custInv/', action: 'whseOnHandQty', query_string: { custNo: current_user, partNo: @whse_prime_part_no, custPartNo: @whse_cust_part_no }
        @shipped_orders_history_response  = invoke_webservice method: 'get', class: 'custInv/', action: 'shippedOrdersHistory', query_string: { custNo: current_user, partNo: @prime_pn }
        @cust_forecast_response           = invoke_webservice method: 'get', class: 'custInv/', action: 'custForecast', query_string: { custNo: current_user, custPartNo: @fc_cust_part_no }
        @cust_forecast_archive_response   = invoke_webservice method: 'get', class: 'custInv/', action: 'custForecast', query_string: { custNo: current_user, custPartNo: @fc_cust_part_no, isArchive: "true" }
        @binParts_response                = invoke_webservice method: 'get', class: 'custInv/', action: 'binParts', query_string: { custNo: current_user, partNo: @whse_cust_part_no }

        # get convert shipDateList to mm/yy date format
        unless @shipped_orders_history_response["shipDateList"].join().blank?
          @shipped_date = EngineeringCheck.extract_month_and_year @shipped_orders_history_response["shipDateList"]
        end

        # get convert ordDateList to mm/yy date format
        unless @shipped_orders_history_response["ordDateList"].join().blank?
          @order_date   = EngineeringCheck.extract_month_and_year @shipped_orders_history_response["ordDateList"]
        end
        #end
        #end
        render 'search_result'
      end
    end
    else
      flash.now[:notice] = "Service temporary unavailable"
      render "index"
    end

  end


  # set the page count
  # set 100 records in to one page, also find the  count of pages
  def show
    params[:page] = params[:page].nil? ? 1 : params[:page]
    @binCenterParts_response  = invoke_webservice method: 'get',class: 'custInv/', action: 'binCenterParts', query_string: {custNo: current_user, binCenter: params[:id].try(:strip),page: params[:page].to_s }
    if @binCenterParts_response
      if @binCenterParts_response["errMsg"].blank?
        @total_records = @binCenterParts_response["totalRecords"].to_i
        @total_page = EngineeringCheck.divide_records_in_pages @total_records
        render 'view_location_parts'
      else
        flash.now[:alert] = @binCenterParts_response["errMsg"]
      end
    else
      flash.now[:notice] = "Service temporary unavailable"
      render "index"
    end
  end

  def download_excel
    #set headers of the xls file
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "attachment; filename=excel_eng_bin_center_parts.xls"
    headers['Cache-Control'] = ''

    # code to create xls file
    require 'writeexcel'
    workbook = WriteExcel.new(Rails.public_path+"/excel/engineering_check/excel_eng_bin_center_parts.xls")
    worksheet  = workbook.add_worksheet("bin_center_parts")

    format = workbook.add_format
    format1 = workbook.add_format
    format.set_bold
    format1.set_color('red')

    @binCenterParts_response = invoke_webservice method: 'get',class: 'custInv/',
                                                 action: 'binCenterParts', query_string: {
            custNo: current_user, binCenter: params[:bin_location]  }
    @shipTo_response  = invoke_webservice method: 'get', class: 'custInv/',
                                          action: 'shipTo', query_string: {
            custNo: current_user }

    @ship_to = @shipTo_response['shipTo'].split('<BR>')

    @ship_to.each_with_index do |value, index_value|
      if value != ""
        worksheet.write(index_value, 0, value, format)
      end
      @row_value = index_value
    end
    # create a table in xls file
    worksheet.write(@row_value+1, 0)
    worksheet.write(@row_value+2, 0)
    worksheet.set_column(0, 0, 20)
    worksheet.set_column(0, 1, 20)
    worksheet.set_column(0, 2, 20)
    worksheet.set_column(0, 3, 20)
    worksheet.set_column(0, 4, 20)
    worksheet.set_column(0, 5, 20)
    worksheet.set_column(0, 6, 20)
    worksheet.set_column(0, 7, 20)

    worksheet.write(@row_value+3, 0, "BIN PARTS FOR LOCATION:")
    worksheet.write(@row_value+3, 1, "#{params[:bin_location]}:#{@binCenterParts_response["whsdesc"][1]}",format1)
    worksheet.write(@row_value+5, 0,"Part Num.", format)
    worksheet.write(@row_value+5, 1,"Scancode", format)
    worksheet.write(@row_value+5, 2,"Whse Desc", format)
    worksheet.write(@row_value+5, 3,"AMC Qty", format)
    worksheet.write(@row_value+5, 4,"Pack Qty", format)
    worksheet.write(@row_value+5, 5,"UM", format)
    worksheet.write(@row_value+5, 6,"BIN", format)
    worksheet.write(@row_value+5, 7,"Qty On-Hand", format)
    worksheet.write(@row_value+5, 8,"Exclude", format)

    # loop for bin center parts data to show in table
    (0..@binCenterParts_response["ref"].length).each do |i|
      worksheet.write(@row_value+6+i,0,@binCenterParts_response["ref"][i])
      worksheet.write(@row_value+6+i,1,@binCenterParts_response["scancode"][i])
      worksheet.write(@row_value+6+i,2,@binCenterParts_response["whsdesc"][i])
      worksheet.write(@row_value+6+i,3,@binCenterParts_response["amcQty"][i])
      worksheet.write(@row_value+6+i,4,@binCenterParts_response["packQty"][i])
      worksheet.write(@row_value+6+i,5,@binCenterParts_response["um"][i])
      worksheet.write(@row_value+6+i,6,@binCenterParts_response["bin"][i])
      worksheet.write(@row_value+6+i,7,@binCenterParts_response["qtyOnHand"][i])
      if @binCenterParts_response["partExclusionList"][i] == "EXCLUDE"
        worksheet.write(@row_value+6+i,8,@binCenterParts_response["partExclusionList"][i])
      else
        worksheet.write(@row_value+6+i,8,"")
      end
    end

    workbook.close
    send_file Rails.public_path+"/excel/engineering_check/excel_eng_bin_center_parts.xls", :disposition => "attachment"
  end

  def print_label
    @engineering_check_print_label = { :part_number => params[:part_number], :location => params[:location], :scan_code => params[:scan_code],
                     :bin => params[:bin], :customer_name => current_customer.user_name}
    respond_to do |format|
      format.html do
        render :pdf => "print_label.html.erb",
               :page_height => '2.5in',
               :page_width => '4in',
               :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
      end
    end

  end

end
