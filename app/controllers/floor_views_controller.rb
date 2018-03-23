class FloorViewsController < ApplicationController
  before_filter :get_locations, :only => [:index, :search_part_number, :search_from_location, :location_page, :send_orders]
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:history_excel,:location_excel]

  def index
  end

  # for viewing the history of floor view orders by default day is 2
  def floor_view_history
    params[:iaction] = "H"
    params[:days]    = "2"
    @floor_view_entry_response = invoke_webservice method: 'get', class: 'custInv/', action:'floorViewEntry', query_string: {custNo: current_user, action: params[:iaction], noOfDays: params[:days] }
    @len                       = @floor_view_entry_response["partNoList"].length
    @days_format               = PanstockRequest.get_select_values
  end

  # when change the days by select box control comes in history_days
  def history_days
    params[:iaction] = "H"
    @floor_view_entry_response = invoke_webservice method: 'get', class: 'custInv/', action:'floorViewEntry', query_string: {custNo: current_user, action: params[:iaction], noOfDays: params[:days] }
    @len                       = @floor_view_entry_response["partNoList"].length
    @days_format               = PanstockRequest.get_select_values
    respond_to do |format|
      format.js
      format.html
    end
  end

  #  for updating the floor view orders
  def update_floor_view
    @bin_center_response = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: {custNo: current_user }
    @sellId              = params[:CFGRIDKEY]
    if @bin_center_response["errCode"] == "1"
      flash[:notice] = "Error - No Bin Center for this Customer."
    end
    @floor_view_entry_response = invoke_webservice method: 'get', class: 'custInv/', action: 'floorViewEntry', query_string: {sellId: @sellId, action: params[:iaction]}
    if @floor_view_entry_response["partNo"] == [""]
      flash[:notice] = "Must enter PartNo"
    else
      @cust_no               = current_user
      @part_no               = @floor_view_entry_response["partNo"]
      @get_binparts_response = invoke_webservice method: 'get', class: 'custInv/', action:'binParts', query_string: {custNo: current_user, partNo: @floor_view_entry_response["partNo"].join()}
      @ref                   = @get_binparts_response["ref"].join(',').split(',').first
      @cust_part_no          = @get_binparts_response["custPartNo"].split(',').first
      @originalPn            = @floor_view_entry_response["originalPN"]
      @total                 = @floor_view_entry_response["orderQty"].inject(0){|sum,item| sum + item.to_i}
    end
  end

  # code for updating the floor view order
  def form_process
    @selShipTo          = current_user
    @AdditionalComments = "Action Code: " +params[:ActionCode]
    params[:AdditionalComments] = @AdditionalComments
    @BuyerName          = session[:full_name]
    @Company            = session[:customer_Name]
    @UserName           = session[:user_name]
    @BuyerID            = ""
    @pn_array           = params[:PartNo]
    @qty_array          = params[:OrderQty]
    @um_array           = params[:UM]
    @deliv_array        = params[:selLocation]
    if session[:BuyerID]
      @BuyerID = session[:BuyerID]
    else
      @BuyerID = ""
    end
    if params[:status] == "Approved"
      @myPRT_LOC_BIN = "#{params[:CustPartNo]}!#{params[:selLocation]}!#{params[:BinCenter]}!#{params[:OrderQty]}!#{params[:PackQty]}!#{params[:ScanCode]}"
      if params[:ScanCode] != ""
        @send_order_response = invoke_webservice method: 'get', action: 'sendOrder', query_string: {locBin: @myPRT_LOC_BIN, partNo:params[:CustPartNo], custNo: current_user, userLogin: session[:user_name]}
        if @send_order_response["errCode"] != ""
          @general_Error = @send_order_response["errMsg"]
          @bad_pns_array = "1|"+"#{params[:OriginalPN]}"+"|"+"#{params[:PackQty]}"+"|"+"#{params[:UM]}"+"|"+"#{params[:selLocation]}"
        else
          @good_pns_array = "1|"+"#{params[:OriginalPN]}"+"|"+"#{params[:PackQty]}"+"|"+"#{params[:UM]}"+"|"+"#{params[:selLocation]}"
        end
      else
        @checkweborder_response = invoke_webservice method: 'post',
                                                    action: 'checkWebOrder',data: {userName: @UserName,userComments: @AdditionalComments,compName: @Company,
                                                                                   custEmail: session[:buyer_email],custName: @BuyerName,custPN: params[:CustPartNo], buyerID: @BuyerID }
        session[:ShipToName] = @checkweborder_response["shipTo"]
        @bad_pns_array = @checkweborder_response["badPns"]
        @good_pns_array = @checkweborder_response["goodPns"]
        @general_Error = @checkweborder_response["errMsg"]
        session[:ErrorCode] = @checkweborder_response["errCode"]
        @BuyerID = session[:BuyerID]
        session[:buyerEmail] = session[:buyer_email]
        session[:fullName] = @BuyerName
        session[:Company] = @Company
        session[:OriginalPN] = params[:OriginalPN]
        if @bad_pns_array != ""
          @bad_pns_array = @bad_pns_array.split("|")
          @badpn = @bad_pns_array[5]
        else
          @badPN = ""
        end
        if params[:status] == "Approved" && @badPN == "Part not on Contract"
          @bad_pns_array       = @bad_pns_array
          @good_pns_array      = ""
          session[:OriginalPN] = params[:OriginalPN]
          @general_Error = ""
          if session[:BuyerID]
            @BuyerID = session[:BuyerID]
          else
            @BuyerID = ""
          end
          session[:buyerEmail]        =         session[:buyer_email]
          params[:AdditionalComments] = ""
          session[:fullName]          = @BuyerName
          session[:Company]           = @Company
          params[:status]             = "Declined"
          params[:statusReason]       = "badPN"
        end
      end
    else
      @bad_pns_array = "1|"+"#{params[:OriginalPN]}"+"|"+"#{params[:PackQty]}"+"|"+"#{params[:UM]}"+"|"+"#{params[:selLocation]}"
      @good_pns_array = ""
      @general_Error = ""
      if session[:BuyerID]
        @BuyerID = session[:BuyerID]
      else
        @BuyerID = ""
      end
      session[:buyerEmail]        = session[:buyerEmail]
      params[:AdditionalComments] = ""
      session[:fullName]          = @BuyerName
      session[:Company]           = @Company
    end
    @reason = ["Expedite part"]
    @shipto_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'shipTo', query_string: {custNo: current_user}
    @bin_center_response = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: {custNo: current_user }
    session[:shiptToAddress] = @shipto_response["shipTo"].html_safe
    @floor_view_entry_response = invoke_webservice method: 'post',class: 'custInv/',
                                                   action: 'floorViewEntry', data: {selId: params[:SelID] ,action: params[:iAction], custNo: current_user,
                                                                                    sendTo: params[:sendTo], lineStation: params[:selLocation],binCenter: params[:BinCenter],
                                                                                    originator: "", originatorPhone: "", originatorPager: "",requestorName: "",
                                                                                    requestorPhone: "",foremanName: params[:ForemanName], foremanPhone:  "",
                                                                                    approvalStatus: params[:status], approvedBy: params[:approvedBy],statusReason:  params[:statusReason],
                                                                                    actionCode: params[:ActionCode].split(","), partNo:  params[:PartNo].split(","), orderQtyList:  params[:OrderQty].split(","),
                                                                                    packQtyList: params[:PackQty].split(","), um: params[:UM].split(","), oneTimeNeed: [""], reason: @reason,
                                                                                    scancode: params[:ScanCode].split(",")  ,custPartNo:  params[:CustPartNo] , originalPN: params[:OriginalPN]}
    if @bad_pns_array != ""
      if params[:status] != "Approved"
        case params[:statusReason]
          when "OO"
            params[:statusReasonIn]  = "On Order"
          when "OL"
            params[:statusReasonIn]  = "Other Location"
          when "MO"
            params[:statusReasonIn]  = "Multiple Orders"
          when "OP"
            params[:statusReasonIn]  = "Ops"
          when "badPN"
            params[:statusReasonIn]  = "Part Not On Contract"
          else
            params[:statusReasonIn] = ""
        end
      else
        params[:statusReasonIn]   = ""
      end
    else
      params[:statusReasonIn]     = ""
    end
    @action    = "5"
    @subject   = "Floor View Action Request"
    @emaildata = render_to_string(:partial=>'approval_email', :layout =>  false)
    @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/', action: 'lineStationUpdateEmail', data: { custNo: current_user, action: @action, subject: @subject, emailBody: @emaildata}
  end
  # create excel sheet for history of floor view orders
  def history_excel
    @iAction = "H"
    # code to create xls file
    require 'writeexcel'
    workbook = WriteExcel.new(Rails.public_path+"/excel/floor_views/excel_list_out.xls")
    worksheet  = workbook.add_worksheet
    format = workbook.add_format
    format1 = workbook.add_format
    format.set_bold
    format.set_color('black')
    format.set_align('left')
    format1.set_color('red')
    @ship_response = invoke_webservice method: 'get', class: 'custInv/', action: 'shipTo', query_string: {custNo: current_user}
    @shipto_response = @ship_response['shipTo']
    @floor_view_entry_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'floorViewEntry', query_string: {custNo: current_user, action: @iAction, noOfDays: params[:days]}
    @ship_to = @ship_response['shipTo'].split('<BR>')
    @ship_to.each_with_index do |value, index_value|
      if value != " "
        worksheet.write(index_value, 0, value)
      end
      @row_value = index_value
    end
    # create a table in xls file
    worksheet.write(@row_value+1, 0)
    worksheet.write(@row_value+2, 0)
    worksheet.write(@row_value+3, 0, t('floor_view_history',:scope => "floor_views.floor_view_history"))
    worksheet.write(@row_value+3, 1, "#{session[:user_name]}", format1)
    worksheet.write(@row_value+5, 0, t('STATUS',:scope => "floor_views._history_days"), format)
    worksheet.write(@row_value+5, 1, t('TYPE',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 1,20)
    worksheet.write(@row_value+5, 2,t('PART_NUMBER',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 2,20)
    worksheet.write(@row_value+5, 3,t('SCANCODE',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 3,20)
    worksheet.write(@row_value+5, 4,t('LINE_STATION',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 4,20)
    worksheet.write(@row_value+5, 5,t('DATE',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 5,20)
    worksheet.write(@row_value+5, 6,t('TIME',:scope => "floor_views._history_days"), format)
    worksheet.set_column(@row_value+5, 6,20)
    # loop for floor view entry data to show in table
    @floor_view_entry_response['partNoList'].each_index do |i|
      if @floor_view_entry_response["approvalStatusList"][i] == "None"
        worksheet.write(@row_value+6+i,0)
      else
        worksheet.write(@row_value+6+i,0,@floor_view_entry_response['approvalStatusList'][i])
      end
      worksheet.write(@row_value+6+i,1,@floor_view_entry_response['actionCodeList'][i])
      worksheet.write(@row_value+6+i,2,@floor_view_entry_response['partNoList'][i])
      worksheet.write(@row_value+6+i,3,@floor_view_entry_response['scancodeList'][i])
      worksheet.write(@row_value+6+i,4,@floor_view_entry_response['lineStationList'][i])
      if !@floor_view_entry_response['actionDateList'][i].nil?
        worksheet.write(@row_value+6+i,5, Date.strptime(@floor_view_entry_response['actionDateList'][i],"%m/%d/%Y").strftime("%Y-%m-%d"))
      else
        worksheet.write(@row_value+6+i,5)
      end
      if !@floor_view_entry_response['actionTimeList'][i].nil?
        worksheet.write(@row_value+6+i,6, Time.strptime(@floor_view_entry_response['actionTimeList'][i],'%I:%M%P').strftime("%H:%M:%S"))
      else
        worksheet.write(@row_value+6+i,6)
      end
    end
    workbook.close
    send_file Rails.public_path+"/excel/floor_views/excel_list_out.xls", :disposition => "attachment"
  end

  #create excel file for the location search result
  def location_excel
    @BinCenter = params[:location]
    # code to create xls file
    require 'writeexcel'
    workbook = WriteExcel.new(Rails.public_path+"/excel/floor_views/bin_list_out.xls")
    worksheet  = workbook.add_worksheet
    format  = workbook.add_format
    format1 = workbook.add_format
    format.set_bold
    format.set_color('black')
    format.set_align('left')
    format1.set_color('red')
    #@bincenter_parts_response = invoke_get_webservice "/custInv/binCenterParts?custNo="+current_user+"&binCenter="+params[:location]+"&page="+params[:page].to_s
    @bincenter_parts_response = invoke_webservice method: 'get', class: 'custInv/', action: 'binCenterParts', query_string: {custNo: current_user, binCenter: params[:location]}
    @ship_response   = invoke_webservice method:'get', class:'custInv/', action:'shipTo', query_string: {custNo: current_user}
    @shipto_response =  @ship_response['shipTo']
    @ship_to         = @ship_response['shipTo'].split('<BR>')
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
    worksheet.set_column(0, 8, 20)
    worksheet.write(@row_value+3, 0, t('bin_parts_for_location',:scope => "floor_views._location_search"))
    worksheet.write(@row_value+3, 1, "#{params[:location]}:#{@bincenter_parts_response["whsdesc"][1]}",format1)
    worksheet.write(@row_value+5, 0,t('PART_NUMBER',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 1,t('Scan_Code',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 2,t('Whse_Desc',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 3,t('amount_quantity',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 4,t('PACK_QTY',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 5,t('UM',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 6,t('bin',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 7,t('on-hand',:scope => "floor_views._location_search"), format)
    worksheet.write(@row_value+5, 8,t('excluded',:scope => "floor_views._location_search"), format)
    # loop for bin center parts data to show in table
    (0..@bincenter_parts_response["ref"].length).each do |i|
      worksheet.write(@row_value+6+i,0,@bincenter_parts_response["ref"][i])
      worksheet.write(@row_value+6+i,1,@bincenter_parts_response["scancode"][i])
      worksheet.write(@row_value+6+i,2,@bincenter_parts_response["whsdesc"][i])
      worksheet.write(@row_value+6+i,3,@bincenter_parts_response["amcQty"][i])
      worksheet.write(@row_value+6+i,4,@bincenter_parts_response["packQty"][i])
      worksheet.write(@row_value+6+i,5,@bincenter_parts_response["um"][i])
      worksheet.write(@row_value+6+i,6,@bincenter_parts_response["bin"][i])
      worksheet.write(@row_value+6+i,7,@bincenter_parts_response["qtyOnHand"][i])
      if @bincenter_parts_response["partExclusionList"][i] == "EXCLUDE"
        worksheet.write(@row_value+6+i,8,@bincenter_parts_response["partExclusionList"][i])
      else
        worksheet.write(@row_value+6+i,8,"")
      end
    end
    workbook.close
    send_file Rails.public_path+"/excel/floor_views/bin_list_out.xls", :disposition => "attachment"
  end
  # search from the part number
  def search_part_number
    if params[:part_number].blank?
      render :index
    else
      @response = invoke_webservice method: 'get',  class: 'custInv/', action: 'partNums',query_string: {custNo: current_user, partNo: params[:part_number].try(:strip).try(:upcase)}
      @get_customer_values = BinLineStation.get_customer_values @response,params[:part_number].try(:strip).upcase
      @prime_pn = EngineeringCheck.get_covert_arr_to_str @response["primePNList"]
      @cust_pn = EngineeringCheck.get_covert_arr_to_str @response["custPartNoList"]
      @lead_time_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'leadTimes',query_string: {custNo: current_user, custPartNo: @prime_pn}
      @ship_to_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'shipTo', query_string: {custNo: current_user}
      if (@get_customer_values).kind_of? Hash
        if @get_customer_values[:customer_ref_number] == ""
          @get_customer_values[:customer_ref_number] = @response["custPartNoList"].first
        end
        @bin_part_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'binParts', query_string: {custNo: current_user, partNo: @response["custPartNoList"].first}
        @quantity_on_hand = invoke_webservice method: 'get', class: 'custInv/',action: 'whseOnHandQty', query_string:
                                                               { custNo: session[:customer_number],
                                                                 partNo: @get_customer_values[:prime_part_number],
                                                                 custPartNo: @get_customer_values[:customer_ref_number] }
      else
        @bin_part_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'binParts', query_string: {custNo: current_user, partNo: params[:part_number].try(:strip).upcase}
        @quantity_on_hand = invoke_webservice method: 'get', class: 'custInv/',
                                              action: 'whseOnHandQty', query_string:
                { custNo: session[:customer_number],
                  partNo: params[:part_number].try(:strip).upcase,
                  custPartNo: '' }
      end
      #@quantity_on_hand          = invoke_webservice method: 'get',  class: 'custInv/', action: 'whseOnHandQty', query_string: {custNo: current_user, partNo: params[:part_number].try(:strip).try(:upcase), custPartNo: params[:part_number].try(:strip).try(:upcase)}
      @suspender_search_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'superSedenceSearch', query_string: {custNo: current_user, partNo: params[:part_number].try(:strip).try(:upcase)}
      if @response
        if @response["errCode"] == ""
          if @response['searchPartList'].length > 0
            @search_part_list = @response['searchPartList']
            @part_list_len = @search_part_list.length
          end
        end
      end
      if @response["custPartNoList"].include?params[:part_number].try(:strip).try(:upcase)
        @whse_cust_part_no = params[:part_number].try(:strip).upcase
      elsif @response["invPNList"].include?(params[:part_number].try(:strip).upcase)
        index_part_number = @response["invPNList"].index(params[:part_number].try(:strip).upcase)
        @whse_cust_part_no = @response["custPartNoList"][index_part_number] unless index_part_number.blank?
      elsif @response["primePNList"].include?(params[:part_number].try(:strip).upcase)
        index_part_number = @response["primePNList"].index(params[:part_number].try(:strip).upcase)
        @whse_cust_part_no = @response["custPartNoList"][index_part_number] unless index_part_number.blank?
      elsif @response["scancodeList"].include?(params[:part_number].try(:strip).upcase)
        @index = @response["scancodeList"].index(params[:part_number].try(:strip).upcase)
        @whse_cust_part_no = @response["custPartNoList"][@index] unless @index.blank?
      else
        @whse_cust_part_no = params[:part_number].try(:strip).upcase
      end
      if @response
        render "index"
      end
    end
  end

  #search from the location
  def search_from_location
    if params[:page].nil?
      params[:page] = 1
    else
      params[:page]
    end
    @bin_center_part_response = invoke_webservice method: 'get', class: 'custInv/', action: 'binCenterParts', query_string: {custNo: current_user, binCenter: params[:location], page: params[:page].to_s }
    # code for pagination
    if @bin_center_part_response
      if(@bin_center_part_response["errCode"] == "0" || @bin_center_part_response["errCode"] == "")
        @total_records =  @bin_center_part_response["totalRecords"].to_i
        @total_page = EngineeringCheck.divide_records_in_pages @total_records
      else
        flash[:notice] =  @bin_center_part_response["errMsg"]
      end
    else
      flash[:notice] =  I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render "index"
  end

  # when changing the page of location search result
  def location_page
    @bin_center_part_response = invoke_webservice method: 'get', class: 'custInv/', action: 'binCenterParts', query_string: {custNo: current_user, binCenter: params[:location], page: params[:page].to_s }
    # code for pagination
    if @bin_center_part_response
      if(@bin_center_part_response["errCode"] == "0" || @bin_center_part_response["errCode"] == "")
        @total_records =  @bin_center_part_response["totalRecords"].to_i
        @total_page = EngineeringCheck.divide_records_in_pages @total_records
      else
        flash[:notice] =  @bin_center_part_response["errMsg"]
      end
    else
      flash[:notice] =  I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render "index"
  end

  #code for create order and send mail to manager
  def send_orders
    if params[:expedit]
      @expedit_arr = []
      @expedit = []
      params[:expedit].each do |i|
        @expedit_arr << i.split('!').join(",").lines.to_a
      end

      @expedit_arr.flatten.each do |i|
        @expedit << i.gsub(/\[\"/,'').split(',')
      end

      @expedit_array = @expedit
      @expedit = @expedit.transpose
      if params[:commit] == "Submit Order" || params[:commit] == "Invia"
        #check weather entered part no is valid or not
        @vld_response = invoke_webservice method: 'get', class: 'custInv/', action:'vldPartNoUM', query_string: {custNo: current_user, UM: @expedit[3].join(","), partNo: @expedit[0].join(",")}
        if @vld_response
          #if error then print the error
          if @vld_response["errMsg"] != ""
            flash.now[:error] =  @vld_response["errMsg"]
          else
            #if valid then update the floorViewEntry table and send mail to manager
            @ApprovalStatusIn = "None"
            @PartNoListIn = @OrderQtyListIn = @PackQtyListIn = @UMListIn = ""
            @selLocationListIn = @ScanCodeListIn = @SendToListIn = @ActionCodeListIn = ""
            @BinCenterListIn       = [""]
            @PrimePNListIn         = @vld_response['primePNList']
            @OriginalPNList        = @vld_response['originalPNList']
            @CustPartNoList        = @vld_response['custPartNoList']
            @InvPNList             = @vld_response['invPNList']
            @ScancodeList          = @vld_response['scancodeList']
            @reasonForActionListIn = []
            @ApprovalStatusList    = []
            @reasonForActionIn = "Expedite part"
            params[:expedit].each_index do |i|
              @reasonForActionListIn[i] = @reasonForActionIn
            end
            @selLocationIn = @expedit[4]
            @selLocationListIn = @selLocationIn
            @selLocationlist = @selLocationListIn.map{|a| [a]}
            # post request for updating the floorViewEntry table
            @floor_view_entry_response = invoke_webservice method: 'post', class: 'custInv/',
                                                           action: 'floorViewEntry', data: {action: "N", custNo: current_user, originator: "",
                                                                                            originatorPhone: "", originatorPager: "",
                                                                                            requestorName: "", requestorPhone:  "", foremanName: "ShopView",
                                                                                            foremanPhone: "", oneTimeNeed: [""],
                                                                                            reasonList: @reasonForActionListIn,  partNo:  @expedit[0].uniq, orderQtyList: @expedit[1],
                                                                                            packQtyList: @expedit[2], umlist: @expedit[3], lineStationList: @selLocationlist,
                                                                                            sendToList: @expedit[6], binCenterList: @BinCenterListIn,
                                                                                            scancodeList: @expedit[5], actionCode: @expedit[7],
                                                                                            approvalStatus: @ApprovalStatusIn, originalPNList: @OriginalPNList, custPartNoList: @CustPartNoList }
            #send mail to managers if no error in floor view response
            if @floor_view_entry_response['errMsg'] == ""
              @myCustNo                                   = current_user
              @iActionIN                                  = "N"
              @ActionCodeIn                               = "Expedite"
              @ForemanNameIn                              = "ShopView"
              @reasonForActionIn                          = "Expedite part"
              @ApprovalStatusIn                           = "None"
              @reasonForActionListIn, @ApprovalStatusList = ""
            end
            #body of the mail
            @emaildata = render_to_string(:partial=>'email_data', :layout => false)
            #post request for sending the mail
            @locations = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: {custNo: current_user }
            @action = "5"
            @subject = "Floor View Action Request"
            @data = { :custNo => current_user, :action => @action, :subject => @subject, :emailBody => @emaildata }
            #@linestation_email_response = invoke_post_webservice "/custInv/lineStationUpdateEmail", @data
            @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/', action: 'lineStationUpdateEmail', data: { custNo: current_user, action: @action, subject: @subject, emailBody: @emaildata}
            if @linestation_email_response['errMsg'] == ""
              flash.now[:notice] = I18n.translate("email_sent",:scope => "bin_line_station.update_line_station")
            end
          end
        end
        render "index"
      else
        respond_to do |format|
          format.html do
            render :pdf => "send_orders.html.erb",
                   :header => { :right => '[page] of [topage]',
                                :line => true},
                   :margin => {:top =>9, :bottom => 22, :left => 12, :right => 12 }
          end
        end
      end
    else
      flash[:notice] = "true"
      redirect_to :back
    end
  end
  ##
  # This action is to print part number label,
  #  based on Bin# selected
  ##
  def print_part_label
    respond_to do |format|
      format.html do
        render :pdf => "print_part_label.html.erb",
               :page_height => '2.5in',
               :page_width => '4in',
               :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
      end
    end
  end
  private
  def get_locations
    @locations = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: {custNo: current_user }
    if @locations
      if(@locations["errCode"] != "")
        flash[:err] = @locations["errMsg"]
      end
    end
    if @locations.nil?
      flash[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
  end
end