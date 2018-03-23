class PanstockRequestsController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:panstock_history_excel]
  def index
    if can?(:>=, "2")
      params[:inputs] = "1"
      @myact = params[:iAction] ? params[:iAction] : ""
      @tpn = params[:tpn] if params[:tpn]
      @ac = params[:ac] if params[:ac]
      @locations = invoke_webservice method: 'get', class: 'custInv/', action:'binCenters', query_string: {custNo: session[:customer_number] }
      if @locations && @locations["errCode"] != "1"
        @bldgLineStations_response = invoke_webservice method: 'get', class: 'custInv/',action:'bldgLineStations', query_string: {custNo: session[:customer_number] }
        if @bldgLineStations_response && @bldgLineStations_response["errMsg"] == ""
          @error = false
          @BldgList = @bldgLineStations_response['bldgList'] if @bldgLineStations_response['bldgList'] != ""
          # @bldgLineStations_response["lineStationList"].map(&:sort)
        else
          @error = true
          flash[:alert] = "Error - No Buildings Found for this Customer."
        end
      else
        @error = true
        flash[:alert] = "Error - No Bin Center for this Customer."
      end
    else
      session[:user_level] == "1" ? (redirect_to  :action => :panstock_history) :  (redirect_to unauthorized_url)
    end
  end

  def get_line_station
    @bldgLineStations_response = invoke_webservice method: 'get', class: 'custInv/',
                                                   action:'bldgLineStations', query_string: {custNo: session[:customer_number] }
    if params[:sendTo].present?
      @line_station = @bldgLineStations_response['lineStationList'][@bldgLineStations_response['bldgList'].index(params[:sendTo])]
      @line_station.is_a?(Array) ? @line_station.sort! : []
    else
      @line_station = ""
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def send_panstock_changes
    @PartNoIn, @UMIn = Array.new(2){[]}
    if params[:iAction] == "U"
      @PartNoIn << params["PartNo"].strip
      @UMIn << params["UM"]
    else
      (1..15).each do |i|
        if params["PartNo_#{i}"] != ""
          @PartNoIn << params["PartNo_#{i}"].strip.upcase
        end
        if params["um_#{i}"] != ""
          @UMIn << params["um_#{i}"]
        end
      end
    end

    @vldPartNoUM_response = call_rbo @PartNoIn,@UMIn
    @ScancodeList = @vldPartNoUM_response["scancodeList"]
    if @vldPartNoUM_response["originalPNList"].nil?
      @OriginalPNList = ""
    else
      @OriginalPNList = @vldPartNoUM_response["originalPNList"]
    end
    a = ","
    @errmsg = @vldPartNoUM_response["errMsg"].gsub(/[\u0080-\u00ff]/,a)
    @myErrMsg =  @errmsg.split(",")
    if @vldPartNoUM_response["errMsg"] != ""
      @errMsgList = []
      @myErrMsg.each do |i|
        @errMsgList << i
      end
      if @errMsgList != []
        if params[:iAction] == "U"
          params[:iAction]         == "I"
          params[:selpanstockIdIn] = params[:selID]
          return render "action_history"
        end
        if params[:iAction] == "N"
          params[:iAction] == ""
          return render "panstock_requests/pan_err"
        end
      end
    else
      if params[:iAction] == "N"
        @actioncode = []
        @orderqty = []
        @OneTimeNeedIn = []
        @reasonForActionIn = []
        @ScancodeList = []

        (1..15).each do |i|
          @actioncode << params["ActionCode_#{i}"]
          if params["OrderQty_#{i}"].present?
            @orderqty << params["OrderQty_#{i}"]
          end
          if params["OneTimeNeed_#{i}"]
            @OneTimeNeedIn << params["OneTimeNeed_#{i}"]
          else
            @OneTimeNeedIn << "No"
          end

          if params["ReasonForAction_#{i}"]
            @reasonForActionIn  << params["ReasonForAction_#{i}"]
          else
            @reasonForActionIn  << "-"
          end
        end
      end

      if params[:iAction] == "U"
        @actioncode        = []
        @orderqty          = []
        @OneTimeNeedIn     = []
        @reasonForActionIn = []
        @ScancodeList      = []
        @actioncode << params[:ActionCode]
        @orderqty << params[:OrderQty]
        @OneTimeNeedIn << params[:OneTimeNeed]
        @reasonForActionIn << params[:ReasonForAction]
      end
      @ApprovalStatusIn = "None"
      @reason = @reasonForActionIn.reject! { |c| c.empty? }
      @pan_stock_entry_response = invoke_webservice method: 'post', class: 'custInv/',
                                                    action: 'panstockEntry', data: {action: params[:iAction],
                                                                                    custNo: session[:customer_number],
                                                                                    sendTo:  params[:sendTo], entryDate: Date.today.strftime("%_m/%d/%y"),
                                                                                    lineStation:  params[:selLocation],
                                                                                    binCenter: params[:Bincenter], originator:  params[:Originator],
                                                                                    originatorPhone: params[:OriginatorPhone],
                                                                                    originatorPager: params[:OriginatorPager], requestorName: params[:RequestorName],
                                                                                    requestorPhone: params[:RequestorPhone], foremanName: params[:ForemanName],
                                                                                    foremanPhone: params[:ForemanPhone],
                                                                                    approvalStatus: @ApprovalStatusIn,	actionCode: @actioncode, orderQty: @orderqty,
                                                                                    um: @UMIn, oneTimeNeed: @OneTimeNeedIn,
                                                                                    reason: @reason, partNo: @PartNoIn,
                                                                                    custPartNoList: @vldPartNoUM_response["custPartNoList"],
                                                                                    invPNList: @vldPartNoUM_response["invPNList"], originalPNList: @OriginalPNList,
                                                                                    scancode: @ScancodeList }
    end
    if @pan_stock_entry_response
      if @pan_stock_entry_response['errMsg'] == "" || @pan_stock_entry_response['errMsg'].nil?
        if session[:autoApprove] == "Y" && session[:user_level] > "3"
          @pan_stock_entry_response["idlist"].each_with_index do |sel_id,i|
            if sel_id.join().present?
              @panstockEntry = invoke_webservice method: 'get', class: 'custInv/',
                                                 action: 'panstockEntry',
                                                 query_string: {selId: sel_id.join(),
                                                                action: "I"}
              if @panstockEntry
                params[:selLocation] = @panstockEntry['lineStation']
                if @panstockEntry['oneTimeNeed']
                  @varOneTimeNeed  = "1-Time: " + @panstockEntry['oneTimeNeed'].join(",")
                else
                  @varOneTimeNeed  = ""
                end
                if @panstockEntry['reason']
                  @varReasonComment = "Reason: " + @panstockEntry['reason'].join(",")
                else
                  @varReasonComment = ""
                end
                @AdditionalCommentsIn = "By: " + @panstockEntry['originator'] + " Phone: "  + @panstockEntry['originatorPhone'] + " Action: " + @panstockEntry['actionCode'].join(",") + @varOneTimeNeed + @varReasonComment
                @checkweborder_response = invoke_webservice method: 'post',
                                                            action: 'checkWebOrder',
                                                            data: { userName: session[:user_name],
                                                                    userComments: @AdditionalCommentsIn,
                                                                    compName: session[:customer_Name],
                                                                    custEmail: session[:buyer_email],
                                                                    custName: session[:full_name],
                                                                    custPN: @panstockEntry['partNo'].first,
                                                                    buyerID: "",
                                                                    custQty: @panstockEntry['orderQty'].join(","),
                                                                    custUM: @panstockEntry['um'].join(","),
                                                                    custDelivery: @panstockEntry['lineStation'],
                                                                    shipto: session[:customer_number],
                                                                    custNo: session[:customer_number],
                                                                    actionCode: @panstockEntry['actionCode'].join(","),
                                                                    actionFlag: 'Results',
                                                                    binID: @panstockEntry['binCenter'],
                                                                    building: @panstockEntry['sendTo'],
                                                                    originator: @panstockEntry["originator"]}
                if @checkweborder_response
                  if @checkweborder_response["errMsg"].blank?
                    @pan_stock_entry_auto_approval_response = invoke_webservice method: 'post',class: 'custInv/',
                                                                                action: 'panstockEntry',
                                                                                data: {selId: @panstockEntry["selId"],
                                                                                       action:  "U",
                                                                                       custNo: session[:customer_number],
                                                                                       sendTo: @panstockEntry["sendTo"],
                                                                                       entryDate:  @panstockEntry["entryDate"],
                                                                                       lineStation: @panstockEntry["lineStation"],
                                                                                       binCenter: @panstockEntry['binCenter'],
                                                                                       originator:  @panstockEntry['originator'],
                                                                                       originatorPhone: @panstockEntry['originatorPhone'],
                                                                                       originatorPager:  @panstockEntry['originatorPager'],
                                                                                       requestorName: @panstockEntry['requestorName'],
                                                                                       requestorPhone:  @panstockEntry['requestorPhone'],
                                                                                       foremanName:  @panstockEntry['foremanName'],
                                                                                       foremanPhone:  @panstockEntry['foremanPhone'],
                                                                                       approvedBy: "Auto Approved",
                                                                                       approvalStatus: "Auto-Approved by #{session[:user_name]}",
                                                                                       statusReason: @panstockEntry['statusReason'],
                                                                                       actionCode: @panstockEntry['actionCode'],
                                                                                       orderQty: @panstockEntry['orderQty'],
                                                                                       um: @panstockEntry['um'],
                                                                                       oneTimeNeed: @panstockEntry['oneTimeNeed'],
                                                                                       reason:  @panstockEntry['reason'],
                                                                                       partNo: @panstockEntry['partNo'],
                                                                                       scancode: @panstockEntry['scancode'],
                                                                                       invPN: @panstockEntry['invPN'],
                                                                                       originalPN: @panstockEntry['originalPN'],
                                                                                       custPartNo: @panstockEntry['custPartNo']}
                    if @pan_stock_entry_auto_approval_response['errCode']
                      flash.now[:alert] = @pan_stock_entry_auto_approval_response['errCode']
                    end
                  else
                    flash.now[:alert] = @checkweborder_response["errMsg"]
                  end
                else
                  flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
                end
              else
                flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
              end
            end
          end
        end
        @action = "5"
        if session[:autoApprove] == "Y" && session[:user_level] > "3"
          @subject = "Panstock Action Request - Auto Approved"
        else
          @subject = "Panstock Action Request"
        end
        @emaildata = render_to_string(:partial => 'panstock_request_mail', :layout => false)
        @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/',
                                                        action: 'lineStationUpdateEmail', data: { custNo: session[:customer_number],
                                                                                                  action: @action, subject: @subject, emailBody: @emaildata}
        if @linestation_email_response["errMsg"] == ""
          if session[:autoApprove] == "Y" && session[:user_level] > "3"
            flash.now[:message] = I18n.translate("auto_approved_email_sent",:scope => "bin_line_station.update_line_station")
          else
            flash.now[:message] = I18n.translate("email_sent",:scope => "bin_line_station.update_line_station")
          end
        else
          redirect_to panstock_requests_path, :method => 'get'
        end
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
  end

  def form_process

    @good_pns_array = ""
    @bad_pns_array  = ""
    @General_Error  = ""
    if params[:status] == "Approved"
      if params[:selShipTo] == ""
        params[:selShipTo] = session[:customer_number]
      end

      if params[:OneTimeNeed]
        @onetime_need = "1-Time: " + params[:OneTimeNeed]
      else
        @onetime_need = ""
        params[:OneTimeNeed] = ""
      end

      if params[:ReasonForAction] && params[:ReasonForAction] != ""
        @varReasonComment = " Reason: " + params[:ReasonForAction]
      else
        @varReasonComment = ""
      end

      @actioncode = Array.new
      @custpartno = Array.new
      @orderqty = Array.new
      @UM  = Array.new

      (1..15).each do |i|
        @actioncode << params["ActionCode_#{i}"]
      end

      #@action_code = @actioncode.join(",")
      @action_code =   params["ActionCode"]
      (1..15).each do |i|
        @custpartno << params["PartNo_#{i}"]
      end
      @custpart_no = @custpartno.join(",")
      (1..15).each do |i|
        @orderqty << params["OrderQty_#{i}"]
      end
      @order_qty = @orderqty.join(",")
      (1..15).each do |i|
        @UM << params["um_#{i}"]
      end
      @um = @UM.join(",")

      #@reason = @action_code.split("").reject! { |c| c.empty? }
      @AdditionalCommentsIn = "By: " + params[:Originator] + " Phone: " + params[:OriginatorPhone] + " Action: " + params[:ActionCode] + @onetime_need + @varReasonComment

      @BuyerName            = session[:full_name]
      @Company              =  session[:customer_Name]
      @buyerID = ""

      if params[:BinCenter]
        @BinIDIn = params[:BinCenter]
      else
        @BinIDIn = ""
      end

      @checkweborder_response = invoke_webservice method: 'post',
                                                  action: 'checkWebOrder',data: { userName: session[:user_name],
                                                                                  userComments: @AdditionalCommentsIn, compName: session[:customer_Name],
                                                                                  custEmail: session[:buyer_email], custName: session[:full_name], custPN: params[:CustPartNo],
                                                                                  buyerID: @buyerID, custQty: params["OrderQty"], custUM: params["UM"], custDelivery: params[:selLocation],
                                                                                  shipto:  session[:customer_number], custNo: session[:customer_number], actionFlag: 'Results',
                                                                                  binID: @BinIDIn, building: params[:sendTo], originator: params[:Originator],actionCode: params["ActionCode"]}



      session[:ShipToName]=@checkweborder_response["shipto"]
      @bad_pns_array = @checkweborder_response["badPns"]
      @good_pns_array = @checkweborder_response["goodPns"]
      @General_Error = @checkweborder_response["errMsg"]


      session[:BuyerID]           = @buyerID
      session[:Email]             = params[:Email]
      params[:AdditionalComments] = @AdditionalCommentsIn
      session[:BuyerName]         = @BuyerName
      session[:Company]           = @Company
      session[:OriginalPN]        = ""
      session[:CID]               = ""

      @shipto_response = invoke_webservice method: 'get',  class: 'custInv/',
                                           action: 'shipTo', query_string: {custNo: session[:customer_number]}

      if @bad_pns_array && @bad_pns_array != ""
        params[:StatusReason] = "declined"
        params[:status] = "Declined"
      end

    else

      @actioncode = Array.new
      @originalpn = Array.new
      @orderqty   = Array.new
      @UM         = Array.new
      @custpartno = Array.new

      @actioncode = params[:ActionCode]
      @originalpn = params[:OriginalPN]
      @orderqty   = params[:OrderQty]
      @UM         = params[:UM]
      @custpartno = params[:CustPartNo]
      @bad_pns_array = "1|" + params[:OriginalPN].to_s + "|" + @orderqty.to_s + "|" + @UM.to_s + "|" + params[:selLocation]
      @good_pns_array = ""
      @General_Error = ""

      if params[:OneTimeNeed] && params[:OneTimeNeed] != ""
        params[:OneTimeNeed] = params[:OneTimeNeed]
      else
        params[:OneTimeNeed] = "No"
      end
      @shipto_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'shipTo', query_string: {custNo: session[:customer_number]}
    end

    if @General_Error == ""
      @SelPanstockIdIn = params[:SelId]
      @EntryDateIn     = Date.today.strftime("%_m/%d/%y")
      @selLocationIn   = params[:selLocation]
      if params[:Bincenter] != ""
        @BinCenterIn= params[:Bincenter]
      else
        @BinCenterIn = ""
      end
      if params[:ApprovedBy].nil?
        @ApprovedByIn = ""
      else
        @ApprovedByIn = params[:ApprovedBy]
      end

      if params[:status].nil?
        @ApprovalStatusIn = ""
      else

        @ApprovalStatusIn = params[:status]
      end

      if params[:StatusReason].nil?
        @StatusReasonIn = ""
      else
        @StatusReasonIn = params[:StatusReason]
      end

      @ActionCodeIn = @action_code
      @OrderQtyIn = @orderqty
      @UMIn = @um
      @onetime_need = Array.new
      @reason_for_action = Array.new
      @onetime_need = params[:OneTimeNeed]
      @OneTimeNeedIn = @onetime_need

      if @OneTimeNeedIn == ""
        @OneTimeNeedIn = ""
      end
      @reason_for_action = params[:ReasonForAction]
      if @reasonForAction == ""
        @reasonForAction = ""
      end
    end

    @pan_stock_entry_response = invoke_webservice method: 'post',class: 'custInv/',action: 'panstockEntry',
                                                  data: {selId: params[:SelID],
                                                         action: params[:iAction],
                                                         custNo: session[:customer_number],
                                                         sendTo: params[:sendTo],
                                                         entryDate: @EntryDateIn,
                                                         lineStation: params[:selLocation],
                                                         binCenter: @BinCenterIn,
                                                         originator: params[:Originator],
                                                         originatorPhone: params[:OriginatorPhone],
                                                         originatorPager: params[:OriginatorPager],
                                                         requestorName: params[:RequestorName],
                                                         requestorPhone: params[:RequestorPhone],
                                                         foremanName: params[:ForemanName],
                                                         foremanPhone: params[:ForemanPhone],
                                                         approvedBy: params[:approvedBy],
                                                         approvalStatus: params[:status],
                                                         statusReason: params[:statusReason],
                                                         actionCode: params[:ActionCode].split(","),
                                                         orderQty: params[:OrderQty].split(","),
                                                         um: params[:UM].split(","),
                                                         oneTimeNeed: params[:OneTimeNeed].split(","),
                                                         reason: params[:ReasonForAction].split(","),
                                                         partNo: params[:PartNo].split(","),
                                                         scancode: params[:Scancode].split(","),
                                                         invPN: params[:InvPN],
                                                         originalPN: params[:OriginalPN],
                                                         custPartNo: params[:CustPartNo]}

    if @pan_stock_entry_response["errCode"] != ""
      flash.now[:message].now = "#{@pan_stock_entry_response["errMsg"]}"
    end

    if @bad_pns_array != ""
      if params[:status] != "Approved"
        if params[:StatusReason] == "OO"
          @StatusReasonIn = "On Order"
        elsif params[:StatusReason] == "OL"
          @statusReasonIn = "Other Location"
        elsif params[:StatusReason] == "MO"
          @StatusReasonIn = "Multiple Orders"
        elsif params[:StatusReason] == "OP"
          @StatusReasonIn = "Ops"
        elsif params[:StatusReason] =="declined"
          @StatusReasonIn = "Declined by System"
        else
          @StatusReasonIn = ""
        end
      else
        @StatusReasonIn = ""
      end
    else
      @StatusReasonIn = ""
    end
    @action    = "5"
    @subject   = "Panstock Action Request"
    @emaildata = render_to_string(:partial=>'update_order_mail',:layout =>  false)
    @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/',
                                                    action: 'lineStationUpdateEmail', data: { custNo: session[:customer_number],
                                                                                              action: @action, subject: @subject, emailBody: @emaildata}
    if @linestation_email_response['errMsg'] == ""
      flash.now[:notice] = I18n.translate("email_sent",:scope => "bin_line_station.update_line_station")
    end
  end

  def panstock_history
    @myCustNo = session[:customer_number]
    @iAction = "H"
    params[:ActionDateList] = ""
    if params[:days].nil?
      params[:days] = "2"
      @pan_stock_entry_response = invoke_webservice method: 'get', class: 'custInv/',
                                                    action: 'panstockEntry',
                                                    query_string: {custNo: session[:customer_number],action:@iAction,noOfDays: params[:days]}
    end
    @len                       = @pan_stock_entry_response["originalPNList"].length
    @days_format               = PanstockRequest.get_select_values

  end

  def panstock_days
    @iAction = "H"
    @pan_stock_entry_response = invoke_webservice method: 'get', class: 'custInv/', action: 'panstockEntry', query_string: {custNo: session[:customer_number],action:@iAction,noOfDays: params[:days]}
    @len                      = @pan_stock_entry_response["partNoList"].length
    @days_format              = PanstockRequest.get_select_values
    respond_to do |format|
      format.js { }
    end
  end

  def panstock_history_excel
    @iAction = "H"
    # code to create xls file
    require 'writeexcel'
    workbook = WriteExcel.new(Rails.public_path+"/excel/panstock_request/excel_list_out.xls")
    worksheet  = workbook.add_worksheet

    format = workbook.add_format
    format1 = workbook.add_format
    format.set_bold
    format.set_color('black')
    format.set_align('left')
    format1.set_color('red')
    @ship_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'shipTo', query_string: {custNo: session[:customer_number]}
    @shipto_response =  @ship_response['shipTo']
    @panstock_entry_response = invoke_webservice method: 'get', class: 'custInv/', action: 'panstockEntry', query_string: {custNo: session[:customer_number], action: @iAction, noOfDays: params[:days]}
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
    worksheet.write(@row_value+3, 0, I18n.translate('Panstock_History',:scope=> "panstock_requests.action_history"))
    worksheet.write(@row_value+3, 1, "#{session[:user_name]}", format1)
    worksheet.write(@row_value+5, 0, I18n.translate('Status',:scope=> "panstock_requests.action_history").upcase, format)
    worksheet.write(@row_value+5, 1, I18n.translate('type',:scope => ".panstock_requests.panstock_history"), format)
    worksheet.set_column(@row_value+5, 1,  20)
    worksheet.write(@row_value+5, 2, I18n.translate('PART_NUMBER',:scope => "panstock_requests._edit_panstock"), format)
    worksheet.set_column(@row_value+5, 2,  20)
    worksheet.write(@row_value+5, 3, I18n.translate('Line_Station',:scope => "panstock_requests.action_history").upcase, format)
    worksheet.set_column(@row_value+5, 4,  20)
    worksheet.write(@row_value+5, 4, I18n.translate('Date',:scope => "panstock_requests._edit_panstock").upcase, format)
    worksheet.set_column(@row_value+5, 5,  20)
    worksheet.write(@row_value+5, 5, I18n.translate('time',:scope => "panstock_requests.panstock_history"), format)
    worksheet.set_column(@row_value+5, 6,  20)
    worksheet.write(@row_value+5, 6, I18n.translate('qty',:scope => "panstock_requests.panstock_history"), format)
    worksheet.set_column(@row_value+5, 6,  20)
    worksheet.write(@row_value+5, 7, I18n.translate('Originator',:scope=> "panstock_requests.action_history").upcase, format)
    worksheet.set_column(@row_value+5, 6,  20)
    # loop for floor view entry data to show in table
    @panstock_entry_response['custPartNoList'].each_index do |i|
      if @panstock_entry_response["approvalStatusList"][i] == "None"
        worksheet.write(@row_value+6+i,0)
      else
        worksheet.write(@row_value+6+i,0,@panstock_entry_response['approvalStatusList'][i])
      end
      worksheet.write(@row_value+6+i,1,@panstock_entry_response['actionCodeList'][i])
      worksheet.write(@row_value+6+i,2,@panstock_entry_response['custPartNoList'][i])
      worksheet.write(@row_value+6+i,3,@panstock_entry_response['lineStationList'][i])

      if !@panstock_entry_response['actionDateList'][i].nil?
        worksheet.write(@row_value+6+i,4, Date.strptime(@panstock_entry_response['actionDateList'][i],"%m/%d/%Y").strftime("%Y-%m-%d"))
      else
        worksheet.write(@row_value+6+i,4)
      end

      if !@panstock_entry_response['actionTimeList'][i].nil?
        worksheet.write(@row_value+6+i,5, Time.strptime(@panstock_entry_response['actionTimeList'][i],'%I:%M%P').strftime("%H:%M:%S"))
      else
        worksheet.write(@row_value+6+i,5)
      end
      worksheet.write(@row_value+6+i,6,@panstock_entry_response['qtyList'][i])
      worksheet.write(@row_value+6+i,7,@panstock_entry_response['originatorList'][i])
    end

    workbook.close
    send_file Rails.public_path+"/excel/panstock_request/excel_list_out.xls", :disposition => "attachment"
  end

  def action_history
    @locations = invoke_webservice method: 'get', class: 'custInv/',
                                   action:'binCenters', query_string: {custNo: session[:customer_number] }

    if @locations['errCode'] == "1"
      flash.now[:notice] = "Error - No Bin Center for this Customer."
    end

    if params[:IDList]
      @SelPanstockIdIN = params[:IDList]
      @ActionIN        = params[:iAction]
    elsif params[:CFGRIDKEY]
      @SelPanstockIdIN = params[:CFGRIDKEY]
      @ActionIN        = params[:act]
    else
      @SelPanstockIdIN = "No Data"
      @ActionIN        = "I"
    end
    @panstockEntry = invoke_webservice method: 'get', class: 'custInv/', action: 'panstockEntry',
                                       query_string: {selId: @SelPanstockIdIN, action: @ActionIN}

    @bldgLineStations = invoke_webservice method: 'get', class: 'custInv/', action:'bldgLineStations',
                                          query_string: {custNo: session[:customer_number] }

    if @bldgLineStations['errMsg'] != ""
      flash.now[:notice] = "Error - No Buildings Found for this  Customer."
    end
  end

  def bulk_history
    if params[:act]
      @iAction = "H"
    end
    @iAction = "H"
    @ActionDateList = ""
    if params[:days].nil?
      params[:days] = "2"
    end
    @pan_stock_entry_response = invoke_webservice method: 'get', class: 'custInv/',
                                                  action: 'panstockEntry',
                                                  query_string: {custNo: session[:customer_number],action:@iAction,noOfDays: params[:days]}
    @len = @pan_stock_entry_response["partNoList"].length
    @days_format = PanstockRequest.get_select_values
  end

  def bulk_history_days
    @iAction                  = "H"
    @ActionDateList           = ""
    @days_format              = PanstockRequest.get_select_values
    @pan_stock_entry_response = invoke_webservice method: 'get', class: 'custInv/',action: 'panstockEntry', query_string: {custNo: session[:customer_number], action: @iAction, noOfDays: params[:days] }
    @len = @pan_stock_entry_response["partNoList"].length
  end

  def bulk_form_process
    @panstock_entry = []
    @IActionIN = "I"
    params[:approval107].each_index do |i|
      @panstockEntry = invoke_webservice method: 'get', class: 'custInv/', action: 'panstockEntry',
                                         query_string: {selId: params[:approval107][i],
                                                        action: @IActionIN}
      params[:selLocation] = @panstockEntry['lineStation']
      @MYApprovalStatus    = "Approved"
      if @MYApprovalStatus == "Approved"
        params[:selShipTo] = session[:customer_number]
        if @panstockEntry['oneTimeNeed']
          @varOneTimeNeed  = "1-Time: " + @panstockEntry['oneTimeNeed'].join(",")
        else
          @varOneTimeNeed  = ""
        end
        if @panstockEntry['reason']
          @varReasonComment = "Reason: " + @panstockEntry['reason'].join(",")
        else
          @varReasonComment = ""
        end
        @AdditionalCommentsIn = "By: " + @panstockEntry['originator'] + " Phone: "  + @panstockEntry['originatorPhone'] + " Action: " + @panstockEntry['actionCode'].join(",") + @varOneTimeNeed + @varReasonComment
        @buyerID = ""
        @checkweborder_response = invoke_webservice method: 'post',
                                                    action: 'checkWebOrder',
                                                    data: { userName: session[:user_name],
                                                            userComments: @AdditionalCommentsIn,
                                                            compName: session[:customer_Name],
                                                            custEmail: session[:buyer_email],
                                                            custName: session[:full_name],
                                                            custPN: @panstockEntry['partNo'].first,
                                                            buyerID: @buyerID,
                                                            custQty: @panstockEntry['orderQty'].join(","),
                                                            custUM: @panstockEntry['um'].join(","),
                                                            custDelivery: params[:selLocation],
                                                            shipto: params[:selShipTo],
                                                            custNo: session[:customer_number],
                                                            actionCode: @panstockEntry['actionCode'].join(","),
                                                            actionFlag: 'Results',
                                                            binID: @panstockEntry['binCenter'],
                                                            building: @panstockEntry['sendTo'],
                                                            originator: @panstockEntry["originator"]}
        @bad_pns_array = Array.new
        @bad_pns_array = @checkweborder_response['badPns'].split("|")
        @good_pns_array= @checkweborder_response['goodPns']
        @General_Error = @checkweborder_response['errMsg']
        @ship_response = invoke_webservice method: 'get',  class: 'custInv/', action: 'shipTo',
                                           query_string: {custNo: session[:customer_number]}
        if @checkweborder_response['badPns'] != ""
          @MYOrder_StatusReason   = "declined"
          @MYOrder_ApprovalStatus = "Declined"
        else
          @MYOrder_ApprovalStatus = "Approved"
        end
      else
        @bad_pns_array = Array.new
        @bad_pns_array = "1|" + params[:OriginalPN] + "|" + params[:OrderQty] + "|" + params[:um] + "|" + params[:selLocation]
        @bad_pns_array = @bad_pns_array.split("|")
        @good_pns_array= @checkweborder_response['goodPns']
        @General_Error = ""
        @buyer_Id = ""
        @BuyerName = session[:full_name]
        @Email = session[:buyer_email]
        @Company = session[:customer_Name]
        @OriginalPN = params[:OriginalPN]
        if @panstockEntry['oneTimeNeed']
          @varOneTimeNeed = "1-Time: " + @panstockEntry['oneTimeNeed'].join(",")
        else
          @varOneTimeNeed = ""
        end
        @ship_response = invoke_webservice method: 'get',  class: 'custInv/',
                                           action: 'shipTo',
                                           query_string: {custNo: session[:customer_number]}
      end
      if @General_Error == ""
        @pan_stock_entry_response = invoke_webservice method: 'post',class: 'custInv/',
                                                      action: 'panstockEntry',
                                                      data: {selId: @panstockEntry["selId"],
                                                             action:  "U",
                                                             custNo: session[:customer_number],
                                                             sendTo: @panstockEntry["sendTo"],
                                                             entryDate:  @panstockEntry["entryDate"],
                                                             lineStation: @panstockEntry["lineStation"],
                                                             binCenter: @panstockEntry['binCenter'],
                                                             originator:  @panstockEntry['originator'],
                                                             originatorPhone: @panstockEntry['originatorPhone'],
                                                             originatorPager:  @panstockEntry['originatorPager'],
                                                             requestorName: @panstockEntry['requestorName'],
                                                             requestorPhone:  @panstockEntry['requestorPhone'],
                                                             foremanName:  @panstockEntry['foremanName'],
                                                             foremanPhone:  @panstockEntry['foremanPhone'],
                                                             approvedBy: params[:ApprovedBy],
                                                             approvalStatus: "Approved",
                                                             statusReason: @panstockEntry['statusReason'],
                                                             actionCode: @panstockEntry['actionCode'],
                                                             orderQty: @panstockEntry['orderQty'],
                                                             um: @panstockEntry['um'],
                                                             oneTimeNeed: @panstockEntry['oneTimeNeed'],
                                                             reason:  @panstockEntry['reason'],
                                                             partNo: @panstockEntry['partNo'],
                                                             scancode: @panstockEntry['scancode'],
                                                             invPN: @panstockEntry['invPN'],
                                                             originalPN: @panstockEntry['originalPN'],
                                                             custPartNo: @panstockEntry['custPartNo']}
        if @pan_stock_entry_response['errCode']
          flash.now[:message] = @pan_stock_entry_response['errCode']
        end
        if !@bad_pns_array.blank?
          params[:StatusReasonIn] = "Declined by System - " + @bad_pns_array[4]
        else
          params[:StatusReasonIn] = "Approved Order Submitted:"
        end
        @panstock_entry << @pan_stock_entry_response
        @action = "5"
        @subject = "Panstock Action Request"
        @emaildata = render_to_string(:partial=>'panstock_bulk_email',:layout =>  false)
        @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/',
                                                        action: 'lineStationUpdateEmail',
                                                        data: { custNo: session[:customer_number],
                                                                action: @action,
                                                                subject: @subject,
                                                                emailBody: @emaildata}
        if @linestation_email_response['errMsg'] == ""
          flash.now[:notice] = "Email sent to managers."
        end
      end
    end if params[:approval107] && params[:approval107].length > 0
  end

  def validate_contract
    @PartNoIn = params["PartNo"]
    @UMIn = params["UOM"]
    @rbo_response = call_rbo @PartNoIn,@UMIn
    @ScancodeList = @rbo_response["scancodeList"]
    if @rbo_response["originalPNList"].nil?
      @OriginalPNList = ""
    else
      @OriginalPNList = @rbo_response["originalPNList"]
    end
    separator = ","
    @errmsg = @rbo_response["errMsg"].gsub(/[\u0080-\u00ff]/,separator)
    if @rbo_response["errMsg"] != ""
      @errMsgList = Array.new
      @errmsg.split(",").each do |i|
        @errMsgList << i
      end
    end
    render :json => {:rbo_resp => @rbo_response , :error => @errMsgList }.to_json
  end

  private

  def call_rbo part,uom
    invoke_webservice method: 'get', class: 'custInv/',action:'vldPartNoUM',query_string: {custNo: session[:customer_number], partNo: part.join(","), UM: uom.join(",") }
  end
end