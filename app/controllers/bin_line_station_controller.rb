class BinLineStationController < ApplicationController
  before_filter :require_part_number, :only => :search_part_number
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:download_excel]

  # GET /bin_line_station
  ##
    # This action is of index page (front page when someone
    #   clicked on Bin Locator link)
    # Showing search page for part number to locate it in remote inventory or vice versa
    #   (used @locations object)
  ##
  def index
    @locations = invoke_webservice method: 'get', class: 'custInv/',
                   action: 'binCenters', query_string: { custNo: session[:customer_number] }
    if(@locations["errCode"] != "")
      flash[:err] = @locations["errMsg"]
    end
  end

  # POST /search_part_number
  ##
    # This action is to show part number search result page,
    #  based on part number entered
  ##
  def search_part_number
    part_number = params[:part_number].try(:strip).upcase
    @customer_values = invoke_webservice method: 'get', class: 'custInv/',
                         action: 'partNums', query_string: { custNo: session[:customer_number],
                         partNo: part_number}
      @get_customer_values = BinLineStation.get_customer_values @customer_values,
                               params[:part_number].try(:strip).upcase
      @shipping_address = invoke_webservice method: 'get', class: 'custInv/',
                              action: 'binParts', query_string:
                              { custNo: session[:customer_number], partNo: part_number }
      @prime_pn = EngineeringCheck.get_covert_arr_to_str @customer_values["primePNList"]

      @lead_times = invoke_webservice method: 'get', class: 'custInv/',
                        action: 'leadTimes', query_string:
                        { custNo: session[:customer_number], custPartNo: @prime_pn }

      if (@get_customer_values).kind_of? Hash
        if @get_customer_values[:customer_ref_number] == ""
          @get_customer_values[:customer_ref_number] = @customer_values["custPartNoList"].first
        end
        @bin_map = invoke_webservice method: 'get', class: 'custInv/',
                                     action: 'binParts', query_string:
                                    { custNo: session[:customer_number], partNo: @get_customer_values[:customer_ref_number] }
        @quantity_on_hand = invoke_webservice method: 'get', class: 'custInv/',
                              action: 'whseOnHandQty', query_string:
                              { custNo: session[:customer_number],
                              partNo: @get_customer_values[:prime_part_number],
                              custPartNo: @get_customer_values[:customer_ref_number] }


      else
        @bin_map = invoke_webservice method: 'get', class: 'custInv/',
                                     action: 'binParts', query_string:
                { custNo: session[:customer_number], partNo: params[:part_number].try(:strip).upcase }
        @quantity_on_hand = invoke_webservice method: 'get', class: 'custInv/',
                              action: 'whseOnHandQty', query_string:
                              { custNo: session[:customer_number],
                              partNo: params[:part_number].try(:strip).upcase,
                              custPartNo: '' }

      end

  end

  ##
    # This action is to show location search result page,
    #  based on location entered
  ##
  def search_by_location
    params[:page] = params[:page].nil? ? 1 : params[:page]
    params[:location] = params[:location].nil? ? "" : params[:location]
    @locations = invoke_webservice method: 'get', class: 'custInv/',
                   action: 'binCenters', query_string: { custNo: current_user  }
    unless @locations["binCenterList"].first.blank?
    @bin_center_part_response = invoke_webservice method: 'get', class: 'custInv/',
                                  action: 'binCenterParts',
                                  query_string: { custNo: current_user,
                                  binCenter: params[:location], page: params[:page].to_s }
    # code for pagination
    @total_records = @bin_center_part_response["totalRecords"].to_i
    @total_page = EngineeringCheck.divide_records_in_pages @total_records
    end
    @shipping_address = invoke_webservice method: 'get', class: 'custInv/',
                   action: 'shipTo', query_string: { custNo: current_user }
  end

  ##
    # This action is used to create xls file for parts at location,
    #   and download the xls file
  ##
  def download_excel
    # code to create xls file
    workbook = WriteExcel.new("#{Rails.public_path}/excel/bin_line_station/bin_list_out.xls")
    worksheet  = workbook.add_worksheet
    format = workbook.add_format
    format1 = workbook.add_format
    format.set_bold
    format.set_color('black')
    format.set_align('left')
    format1.set_color('red')

    @bin_center_parts = invoke_webservice method: 'get', class: 'custInv/',
                          action: 'binCenterParts',
                          query_string: { custNo: current_user, binCenter: params[:location] }
    @ship_to           = invoke_webservice method: 'get', class: 'custInv/', action: 'shipTo',
                          query_string: { custNo: current_user }
    @ship_to['shipTo'].split('<BR>').each_with_index do |value, index|
      worksheet.write(index, 0, value, format) if value != ""
      @row_value = index
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
    worksheet.write(@row_value+3, 0, I18n.translate('bin_part_loc',:scope => "bin_line_station.download_excel") )
    worksheet.write(@row_value+3, 1,
      "#{params[:location]}:#{@bin_center_parts["whsdesc"][1]}", format1)
    worksheet.write(@row_value+5, 0,I18n.translate('part_num',:scope => "bin_line_station.download_excel"), format)
    worksheet.write(@row_value+5, 1,I18n.translate('scan_code',:scope => "bin_line_station.download_excel"), format)
    worksheet.write(@row_value+5, 2,I18n.translate('whse_desc',:scope => "bin_line_station.download_excel"), format)
    worksheet.write(@row_value+5, 3,I18n.translate('amc_qty',:scope => "bin_line_station.new_part_to_location"), format)
    worksheet.write(@row_value+5, 4,I18n.translate('pack_qty',:scope => "bin_line_station.new_part_to_location"), format)
    worksheet.write(@row_value+5, 5,I18n.translate('UM',:scope => "panstock_requests.send_panstock_changes"), format)
    worksheet.write(@row_value+5, 6,I18n.translate('Bin',:scope => "panstock_requests.send_panstock_changes").upcase, format)
    worksheet.write(@row_value+5, 7,I18n.translate('qty_on_hand',:scope => "bin_line_station.download_excel"), format)
    worksheet.write(@row_value+5, 8,I18n.translate('exclude',:scope => "bin_line_station.search_by_location"), format)

    # loop for bin center parts data to show in table
    (0..@bin_center_parts["ref"].length).each do |i|
      worksheet.write(@row_value+6+i,0,@bin_center_parts["ref"][i])
      worksheet.write(@row_value+6+i,1,@bin_center_parts["scancode"][i])
      worksheet.write(@row_value+6+i,2,@bin_center_parts["whsdesc"][i])
      worksheet.write(@row_value+6+i,3,@bin_center_parts["amcQty"][i])
      worksheet.write(@row_value+6+i,4,@bin_center_parts["packQty"][i])
      worksheet.write(@row_value+6+i,5,@bin_center_parts["um"][i])
      worksheet.write(@row_value+6+i,6,@bin_center_parts["bin"][i])
      worksheet.write(@row_value+6+i,7,@bin_center_parts["qtyOnHand"][i])
      if @bin_center_parts["partExclusionList"][i] == "EXCLUDE"
      worksheet.write(@row_value+6+i,8,@bin_center_parts["partExclusionList"][i])
      else
      worksheet.write(@row_value+6+i,8,"")
      end
    end

    workbook.close
    send_file "#{Rails.public_path}/excel/bin_line_station/bin_list_out.xls", :disposition => "attachment"
  end

  ##
    # This action is to initialize form values for Adding new part to Location or Updating BinLine Station
    # This page is only authorized to userlevel greater than or equal to 2
  ##
  def new_part_to_location
    if can?(:>=, "2")

		else
			redirect_to  unauthorized_url
		end
  end

  ##
    # This action is to Update BinLine Station, by sending mail to manager
  ##

  def update_line_station
    if params[:commit] == "Submit Changes" || params[:commit] == "Invia modifiche"
      @customer_number = session[:customer_number]
      if params[:delete_part] == "true"
        @myaAction = "D"
      else
        @myaAction = "E"
      end
      email_data = render_to_string "_email_data", layout: false
      @linestation_email_response = invoke_webservice method: 'post', class: 'custInv/',
                      action: 'lineStationUpdateEmail', data: { custNo: @customer_number,
                      action: @myaAction, subject: 'Bin Line Station Action Request',
                      emailBody: email_data }
    else
      respond_to do |format|
        format.html do
          render :pdf => "update_line_station.html.erb",
               :page_height => '2.5in',
               :page_width => '4in',
               :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
        end
      end
    end
  end

  ##
    # This action is to Adding part number to Location, by sending mail to manager
  ##
  def create_part_to_location
    @customer_number = session[:customer_number]
    @full_name = session[:full_name]
    @username = session[:user_name]
    email_body = render_to_string "_email_body", layout: false
    @linestation_update_email_response = invoke_webservice method: 'post', class: 'custInv/',
                      action: 'lineStationUpdateEmail', data: { custNo: @customer_number,
                      action: 'N', subject: 'Bin Line Station Action Request',
                      partNo: params[:part_number].try(:strip).upcase.split(), emailBody: email_body }

      if @linestation_update_email_response["errCode"] == "5" || @linestation_update_email_response["errCode"] == "4"
        flash[:notice] = @linestation_update_email_response["errMsg"]
        flash[:part_number] = params[:part_number].try(:strip).upcase
        flash[:amc_qty] = params[:amc_qty]
        flash[:pack_qty] = params[:pack_qty]
        flash[:bin] = params[:bin]
        flash[:reference] = params[:reference]
        redirect_to :back
      else
        flash.now[:alert] = "Update Emails sent to managers."
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

  protected
  # Method to ensure part number field is not left blank
  def require_part_number
    if params[:part_number].blank?
      flash[:alert] = 'Please enter a part number'
      @locations = invoke_webservice method: 'get', class: 'custInv/',
        action: 'binCenters', query_string: { custNo: session[:customer_number] }
      render :index
    end
  end

#  def require_location
#    if params[:location].blank?
#      flash[:alert] = 'Please enter a part number'
#      @locations = invoke_webservice method: 'get', class: 'custInv/',
#        action: 'binCenters', query_string: { custNo: session[:customer_number] }
#      render :index
#    end
#  end
end
