class RmaController < ApplicationController
  before_filter :get_menu_id

  def show

  end

  def search_invoice
    params[:page] = params[:page].nil? ? 1 : params[:page]
    from_date = yyyy_to_yy(params[:begin_date_rma]) if params[:begin_date_rma]
    to_date = yyyy_to_yy(params[:end_date_rma]) if params[:end_date_rma]

    @response_invoices = invoke_webservice method: 'get', action: 'rmaSearchInvoices',
                                           query_string: { custNo: current_user,
                                                           invoiceNo:  params[:invoice_number],
                                                           custPoNo: params[:po_number],
                                                           partNo: params[:part_number],
                                                           ordQty: params[:qty],
                                                           fromDate: from_date,
                                                           toDate: to_date
                                           }
    if @response_invoices
      if(@response_invoices["errCode"] != "")
        @response_invoices["errMsg"] = @response_invoices["errMsg"]
      else
        invoices_present = 0
        @response_invoices["errMsgs"].each do |err|
          invoices_present = invoices_present + 1 if err.blank?
        end
        @response_invoices["errMsg"] = t('rma.no_invoices') if (invoices_present == 0)
        if @response_invoices["errMsg"].blank?
          @length = @response_invoices["partNos"].length
          @result = @response_invoices["partNos"].paginate(params[:page],100)
        end
      end
    else
      flash.now[:error] = t('rma.error.service_unavailable')
    end
    render :show
  end

  def invoice_details
    @year = ""
    @year = params["date"].split("/")[2] if params["date"]

    @invoice_detail = invoke_webservice method: 'get', action: 'rmaInvoiceDetail',
                                        query_string: { invoiceNo: params[:invoice_num],
                                                        invoiceYear:  @year
                                        }

    if @invoice_detail
      if @invoice_detail["errCode"] != ""
        flash.now[:error] = @invoice_detail["errMsg"]
      else
        if @invoice_detail["errMsg"] == "" && params[:disable_fields] == "1"
          @rma_details = invoke_webservice method: 'get', action: 'rmaSearchDetails',
                                           query_string: { rmaNo: params[:rma] }
          if @rma_details
            flash.now[:error] = @rma_details["errMsg"] if @rma_details["errCode"] != ""
          else
            flash.now[:error] = t('rma.error.service_unavailable')
          end
        end
      end
    else
      flash.now[:error] = t('rma.error.service_unavailable')
    end
  end

  def preview_rma_request
    @params =  params
  end

  def inquiry

  end

  def submit
    data_hash = Rma.data_hash_for_creating_rma(params,session[:user_name])
    response = invoke_webservice method: 'post', action: 'createRMA', data: data_hash
#    FileUtils.rm_rf(Rails.root.to_s + "/public/tmp")
    if APP_CONFIG['temp_image_path'].present?
      FileUtils.rm_rf File.join("#{Rails.root}/#{APP_CONFIG['temp_image_path']}")
    end
    if response
      if response["errCode"] == ""
        flash[:notice] = t('rma.rma_creation_msg')
      else
        flash[:error] = response["errMsg"]
      end
    else
      flash[:error] = t('rma.error.service_unavailable')
    end
    redirect_to :controller => "rma", :action => "show"
  end

  def save_img
    @src_path = Rma.save_images(params)
    respond_to do |format|
      format.js { render :content_type => "text/plain" } # needed for IE
    end
#    respond_to :js
  end

  def rma_search
    params[:open_page] = params[:open_page].nil? ? 1 : params[:open_page]
    data_hash = Rma.data_hash_for_rma_search(params,current_user,"1",params[:open_page])
#    threads = []
#    threads << Thread.new {
    @response_open_rma = invoke_webservice method: 'post', action: 'rmaSearch', data: data_hash
    if @response_open_rma
      if @response_open_rma["errCode"] != ""
        if @response_open_rma["errCode"] == "5"
          @response_open_rma["errMsg"] = t('rma.error.open_rma_not_found')
        else
          flash.now[:error] = @response_open_rma["errMsg"]
        end
      else
        if(@response_open_rma["rmaNos"].first.blank?)
          @response_open_rma["errMsg"] = t('rma.error.open_rma_not_found')
        else
          @totalpage_open_rma = @response_open_rma["totalPageCount"].to_i
          @totalrecord_open_rma = @response_open_rma["totalLineCount"].to_i
          @result_open_rma = Array.new(50*@totalpage_open_rma).paginate(params[:open_page],50)
        end
      end
    else
      flash.now[:error] = t('rma.error.service_unavailable')
    end
#    }
#    threads << Thread.new{
    params[:closed_page] = params[:closed_page].nil? ? 1 : params[:closed_page]
    data_hash = Rma.data_hash_for_rma_search(params,current_user,"4",params[:closed_page])
    @response_closed_rma = invoke_webservice method: 'post', action: 'rmaSearch', data: data_hash
    if @response_closed_rma
      if @response_closed_rma["errCode"] != ""
        if @response_closed_rma["errCode"] == "5"
          @response_closed_rma["errMsg"] = t('rma.error.closed_rma_not_found')
        else
          flash.now[:error] = @response_closed_rma["errMsg"]
        end
      else
        if(@response_closed_rma["rmaNos"].first.blank?)
          @response_closed_rma["errMsg"] = t('rma.error.closed_rma_not_found')
        else
          @totalpage_closed_rma = @response_closed_rma["totalPageCount"].to_i
          @totalrecord_closed_rma = @response_closed_rma["totalLineCount"].to_i
          @result_closed_rma = Array.new(50*@totalpage_closed_rma).paginate(params[:closed_page],50)
        end
      end
    else
      flash.now[:error] = t('rma.error.service_unavailable')
    end
#    }
#    threads.each(&:join)
    render :inquiry
  end

  def details
    @rma_details = invoke_webservice method: 'get', action: 'rmaSearchDetails',
                                     query_string: { rmaNo: params[:rma_no] }
    render :partial => "rma_details"
  end
  # Print Packing Slip
  def print_details
    @rma_print_details = invoke_webservice method: 'get', action: 'rmaSearchDetails', query_string: { rmaNo: params[:rma_no] }
    if @rma_print_details && @rma_print_details["rmaWebChevron"] > "1"
      status_message = print params[:rma_no]
      render json: { :status => "Approved" ,:message => status_message }.to_json
    else
      @rma_print_details.present? ? (render json: { :status =>"UnApproved" }.to_json) : (render json: { :status =>"SERVICE UNAVAILABLE" }.to_json)
    end
  end

  def send_message
    @rma_no = params[:rma_no]
    @invoice_no = params[:invoice_no]
    @current_status = params[:current_status]
    rma_details = invoke_webservice method: 'get', action: 'rmaSearchDetails',
                                    query_string: { rmaNo: @rma_no }
    if rma_details.present?
      @part_numbers = rma_details["rmaPrimePns"] unless rma_details.blank?
      @part_quantities = rma_details["rmaRetQtys"] unless rma_details.blank?
      rma_details_table = ''
      if @part_numbers.present? && @part_quantities.present?
        rma_details_table = render_to_string '_rma_email_data', layout: false
      end
    end
    if params[:body] && !(@rma_no.blank? || @invoice_no.blank? || @current_status.blank? || rma_details.blank?)
      params[:body] = ("Customer Notes:" + "\n" + params[:body] +"\n" + "--------------------------------------------\n" + "RMA Details" + "\n" + rma_details_table)
    end
    data_hash = Rma.data_hash_for_sending_rma_email(params,session[:customer_number])
    @response_send_email = invoke_webservice method: 'post', action: 'sendRmaEmail', data: data_hash
    if @response_send_email
      if @response_send_email["errMsg"] != ""
        flash[:error] = @response_send_email["errMsg"]
      else
        flash[:success] = "Email sent successfully"
      end
    else
      flash[:error] = t('rma.error.service_unavailable')
    end
    redirect_to :back
  end

  ##
  # This action is to print slip through RBO call
  # RBO will generate slips in server path
  ##
  private

  # Converts 'mm/dd/yyyy' date format into 'mm/dd/yy' format
  def yyyy_to_yy(date_str)
    split_date = date_str.split("/") if date_str
    date_year = split_date[2].to_i % 100 if split_date[2]
    formatted_date = split_date[0] + "/" + split_date[1] + "/" + date_year.to_s
    formatted_date
  end

  # Not being used now. It's calling the RBO to get sequence
  def image_path
    response = invoke_webservice method: 'get', action: 'newDocId'
    docid = response["newDocId"]
    zero_padded = docid.rjust(12, '0')
    path = APP_CONFIG['rma_image_path'] + zero_padded.first(3) + "/" + zero_padded.first(6) + "/" + zero_padded.first(9) + "/" + zero_padded
    path
  end

  def print rma_no
    @response_print = invoke_webservice method: 'get', action: 'rmaEmailPackingSlip', query_string: { rmaNo: rma_no, userId: session["user_name"]}
    if @response_print
      if @response_print["errMsg"] != ""
        return @response_print["errMsg"]
      else
        return "Packing slip emailed, Please check your inbox"
      end
    else
      return I18n.translate("service_unavailable",:scope => "rma.error")
    end
  end
end
