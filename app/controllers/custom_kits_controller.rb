class CustomKitsController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only => [:download_excel]
  before_filter :fill_search_list, :only => [:index]
  before_filter :check_custom_kit_report, :only => [:custom_kit_report,:delivery_report]
  before_filter :add_date_and_page, :only => [:delivery_report,:search_status,:download_excel]
  before_filter :retrieve_data, :only => [:delivery_report,:download_excel]

  def index
    if can?(:>=, "2")
      @aircraft_details = AgustaAircraftDetail.where(customer_number: session[:customer_number]).pluck(:aircraft_id)
    else
      redirect_to unauthorized_url
    end
  end

  def delivery_report
    if @delivery_report
      if ( @delivery_report["errCode"] == "" || @delivery_report["errMsg"]== "" )
        # if @delivery_report["errMsg"].blank?
        #   @totalpage = @delivery_report["totalPageCount"].to_i
        #   @totalrecord = @delivery_report["totalLineCount"].to_i
        #   @result = Array.new(@totalrecord*@totalpage).paginate(params[:page],100)
        # end
      else
        @delivery_report = t(@delivery_report["errMsg"], :scope => 'custom_kits.errors', :default => @delivery_report["errMsg"])
      end
    else
      @delivery_report = t('rma.error.service_unavailable')
    end
  end

  def custom_kit_report

  end

  def download_excel
    if params[:download_search_status].present?
      params[:page] = params[:page].nil? ? 1 : params[:page]
      time = (Time.now + 1.day).beginning_of_day
      from_date = ( time - params[:date_range].to_i.days).strftime("%m/%d/%Y") rescue ""
      to_date = Time.now.strftime("%m/%d/%Y") rescue ""
      # Search parameter -------------
      input_data = {
          custNo: session[:customer_number],
          # searchBy: params[:search_by_select_value],
          searchBy: "1",
          searchVal: params[:search_status_kit_pn].to_s,
          ordFromDate: from_date,
          ordToDate: to_date,
          shift: params[:shift],
          # createdBy: params[:user_name],
          # inOrderStatus: params[:order_status],
          # orderInputSource: params[:order_source],
          page: params[:page].to_s,
          lpp: "100"
      }

      # Search parameter -------------
      @inquiry_search_details = invoke_webservice method: 'post', action: 'orderInquiry', data: input_data
      workbook = WriteExcel.new("#{APP_CONFIG['conversion_report_path']}/search_status_details.xls")
      worksheet = workbook.add_worksheet
      format = workbook.add_format
      format.set_bold
      format.set_color('black')
      format.set_align('left')
      format.set_font('Trebuchet MS')
      format.set_size(11)
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

      (0..@inquiry_search_details["kitPartNo"].length-1).each do |i|
        worksheet.write(@row_value+2+i, 0, @inquiry_search_details["custName"][i])
        worksheet.write(@row_value+2+i, 1, @inquiry_search_details["requestIdList"][i])
        worksheet.write(@row_value+2+i, 2, @inquiry_search_details["orderNoList"][i])
        worksheet.write(@row_value+2+i, 3, @inquiry_search_details["kitPartNo"][i])
        worksheet.write(@row_value+2+i, 4, @inquiry_search_details["primePns"][i])
        worksheet.write(@row_value+2+i, 5, @inquiry_search_details["custRefPns"][i])
        worksheet.write(@row_value+2+i, 6, @inquiry_search_details["orderStatus"][i])
        worksheet.write(@row_value+2+i, 7, @inquiry_search_details["pnOrderQty"][i])
        worksheet.write(@row_value+2+i, 8, @inquiry_search_details["pnShipStatus"][i])
        worksheet.write(@row_value+2+i, 9, @inquiry_search_details["pnShipQtys"][i])
        worksheet.write(@row_value+2+i, 10, @inquiry_search_details["shipDate"][i])
        worksheet.write(@row_value+2+i, 11, @inquiry_search_details["shipTime"][i])
        worksheet.write(@row_value+2+i, 12, @inquiry_search_details["carrierName"][i])
        worksheet.write(@row_value+2+i, 13, "")
        worksheet.write(@row_value+2+i, 14, "")
        worksheet.write(@row_value+2+i, 15, @inquiry_search_details["assembly"][i])
        worksheet.write(@row_value+2+i, 16, @inquiry_search_details["stations"][i])
        worksheet.write(@row_value+2+i, 17, @inquiry_search_details["requiredDate"][i])
        worksheet.write(@row_value+6+i, 18, @inquiry_search_details["requiredTime"][i])
        worksheet.write(@row_value+2+i, 19, @inquiry_search_details["orderDate"][i])
        worksheet.write(@row_value+2+i, 20, @inquiry_search_details["orderTime"][i])
        worksheet.write(@row_value+2+i, 21, @inquiry_search_details["requester"][i])
        worksheet.write(@row_value+2+i, 22, @inquiry_search_details["operation"][i])
        worksheet.write(@row_value+2+i, 23, @inquiry_search_details["reason"][i])
        worksheet.write(@row_value+2+i,24,((@inquiry_search_details["note"][i].present? ? @inquiry_search_details["note"][i] : "" ) if @inquiry_search_details["note"].present?))
        worksheet.write(@row_value+2+i,25,((@inquiry_search_details["deliveryScanCode"][i].present? ? @inquiry_search_details["deliveryScanCode"][i] : "N/A" ) if @inquiry_search_details["deliveryScanCode"].present?))
      end
      workbook.close
      send_file "#{APP_CONFIG['conversion_report_path']}/search_status_details.xls", :disposition => "attachment"

    else
      if ( @delivery_report && @delivery_report["errCode"] == "" || @delivery_report["errMsg"]== "" )
        workbook = WriteExcel.new("#{APP_CONFIG['conversion_report_path']}/delivery_report_details.xls")
        worksheet = workbook.add_worksheet
        format = workbook.add_format
        format.set_bold
        format.set_color('black')
        format.set_align('left')
        format.set_font('Trebuchet MS')
        format.set_size(11)
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

        worksheet.write(@row_value, 0, I18n.t('custom_kits.delivery_reports.aircraftSn'), format)
        worksheet.set_column(@row_value, 0, 40)
        worksheet.write(@row_value, 1, I18n.t('custom_kits.delivery_reports.sta'), format)
        worksheet.write(@row_value, 2, I18n.t('custom_kits.delivery_reports.dateOrder'), format)
        worksheet.write(@row_value, 3, I18n.t('custom_kits.delivery_reports.reqId'), format)
        worksheet.write(@row_value, 4, I18n.t('custom_kits.delivery_reports.kitMaster'), format)
        worksheet.write(@row_value, 5, I18n.t('custom_kits.delivery_reports.dueDate'), format)
        worksheet.set_column(5, 0, 30)
        worksheet.write(@row_value, 6, I18n.t('custom_kits.delivery_reports.dueTime'), format)
        worksheet.write(@row_value, 7, I18n.t('custom_kits.delivery_reports.binLocation'), format)

        (0..@delivery_report["aircraftSn"].length-1).each do |i|
          worksheet.write(@row_value+1+i, 0, @delivery_report["aircraftSn"][i])
          worksheet.write(@row_value+1+i, 1, @delivery_report["sta"][i])
          worksheet.write(@row_value+1+i, 2, @delivery_report["dateOrder"][i])
          worksheet.write(@row_value+1+i, 3, @delivery_report["reqId"][i])
          worksheet.write(@row_value+1+i, 4, @delivery_report["kitMaster"][i])
          worksheet.write(@row_value+1+i, 5, @delivery_report["dueDate"][i])
          worksheet.write(@row_value+1+i, 6, @delivery_report["dueTime"][i])
          worksheet.write(@row_value+1+i, 7, @delivery_report["binLocation"][i])
        end
        workbook.close
        send_file "#{APP_CONFIG['conversion_report_path']}/delivery_report_details.xls", :disposition => "attachment"
      end
    end
  end

  def search_status
    params[:page] = params[:page].nil? ? 1 : params[:page]
    time = (Time.now + 1.day).beginning_of_day
    from_date = ( time - params[:date_range].to_i.days).strftime("%m/%d/%Y") rescue ""
    to_date = Time.now.strftime("%m/%d/%Y") rescue ""
    # Search parameter -------------
    input_data = {
        custNo: session[:customer_number],
        # searchBy: params[:search_by_select_value],
        searchBy: "1",
        searchVal: params[:search_status_kit_pn].to_s,
        ordFromDate: from_date,
        ordToDate: to_date,
        shift: params[:shift],
        # createdBy: params[:user_name],
        # inOrderStatus: params[:order_status],
        # orderInputSource: params[:order_source],
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
        @aircraft_details = AgustaAircraftDetail.where(customer_number: session[:customer_number]).pluck(:aircraft_id)
      else
        @inquiry_search_details = t(@inquiry_search_details["errMsg"], :scope => 'agusta.errors', :default => @inquiry_search_details["errMsg"])
        @aircraft_details = AgustaAircraftDetail.where(customer_number: session[:customer_number]).pluck(:aircraft_id)
      end
    else
      @inquiry_search_details = t('rma.error.service_unavailable')
      @aircraft_details = AgustaAircraftDetail.where(customer_number: session[:customer_number]).pluck(:aircraft_id)
    end
    fill_search_list
  end

  def get_kit_part_numbers
    if params[:aircraft_id].present?
      @aircraft_ids = AgustaAircraftDetail.find_by_aircraft_id_and_customer_number(params[:aircraft_id],session[:customer_number])
      @kit_part_nos = @aircraft_ids.kit_part_numbers.split(/,/).sort unless @aircraft_ids.nil?
    else
      @error = "NO Aircraft Detail available"
    end
  end

  private

  def check_custom_kit_report
    @custom_kit_report = true
  end

  def add_date_and_page
    params[:page] = params[:page].nil? ? 1 : params[:page]
    @time = (Time.now + 1.day).beginning_of_day
    @from_date = ( @time - params[:date_range].to_i.days).strftime("%m/%d/%Y") rescue ""
    @to_date = Time.now.strftime("%m/%d/%Y") rescue ""
  end

  def retrieve_data
    unless params[:download_search_status].present?
      input_data = {
          custNo: session[:customer_number],
          ordFromDate: @from_date,
          ordToDate: @to_date,
          requestId: params[:request_id],
          page: params[:page].to_s,
          lpp: "100"
      }
      @delivery_report = invoke_webservice method: 'get', class: 'report/',action: 'deliveryReport', query_string: input_data
    end
  end
end
