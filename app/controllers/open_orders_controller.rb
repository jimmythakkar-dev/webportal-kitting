class OpenOrdersController < ApplicationController
  before_filter :validate_values, only: 'search'
  before_filter :get_menu_id

  ##
  # This action is of index page (front page when someone
  #   clicked on Open Order Status link)
  # Showing search page for open orders
  #   (used default @days_format and @search_by_values object)
  ##
  def index
    #default values for days to be rendered in view
    @days_format = OpenOrder.get_select_values
    #default values for search by values to be rendered in view
    @search_by_values = OpenOrder.get_search_values
  end

  ##
  # This action is to show open order search result page,
  #  based on selected search by and date range value
  # If search by value is "all", it sends all open orders to buyer email
  # otherwise it will display all open orders and shipped orders for corresponding
  #  search criteria
  ##
  def search
    #default values for days to be rendered in view
    @days_format = OpenOrder.get_select_values
    #default values for search by values to be rendered in view
    @search_by_values = OpenOrder.get_search_values
    #checking whether search by value is "all"
    if params[:search_by].include? "all"
      # ITR: Threading of “All Open Order” request
      # Creating a Thread to Send mail in Background Process.
      thread = Thread.new { invoke_webservice method: 'post', action: 'openOrders', data: { custNo: current_user,custEm: session[:buyer_email]} }
      at_exit { thread.join }
      @response_send_open_orders = thread.status
      flash.now[:notice] = I18n.translate("mail_msg",:name => session[:buyer_email],:scope => "open_orders.search")
      #checking whether response from webservice is not null
      # if @response_send_open_orders
      # #checking whether errCode variable from response is 0 or ""
      #   if @response_send_open_orders["errCode"] == "0" ||  @response_send_open_orders["errCode"] == ""
      #     flash.now[:notice] = I18n.translate("mail_msg",:name => session[:buyer_email],:scope => "open_orders.search")
      #   #if errCode variable from response is 0 or ""
      #   else
      #     flash.now[:notice] = @response_send_open_orders["errMsg"]
      #   end
      #  #End of checking whether errCode variable from response is 0 or ""
      #  #if response from webservice is null
      # else
      #   flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
      # end
      #End of checking whether response from webservice is not null
      render :index
      #if search by value is other than "all"
    else
      search_for = params[:search_for].try(:strip).try(:upcase)
      search_by = params[:search_by]
      search_start_date = (Time.now - params[:start_date].to_i.days).strftime("%m/%d/%Y")
      search_end_date = Time.now.strftime("%m/%d/%Y")
      #checking whether search by value is "pn"(part number)
      if params[:search_by] != "po"
        search_part_number = params[:search_for].try(:upcase)
        search_purchase_order = ""
        #checking whether search by value is "po"(purchase order number)
      else
        search_part_number = ""
        search_purchase_order = params[:search_for].try(:upcase)
      end
      @response_orders = invoke_webservice method: 'get', action: 'orderStatus',
                                           query_string: { custNo: current_user,
                                                           srch:  search_for,
                                                           srchPNs: "",
                                                           srchBy: search_by,
                                                           srchPoNo: search_purchase_order,
                                                           srchPN: search_part_number,
                                                           srchBdt: search_start_date,
                                                           srchEdt: search_end_date
                                           }
      #checking whether response from webservice is not null
      if @response_orders
        #checking whether errCode variable from response 2
        if @response_orders["openOrders"]["errCode"] == "2"
          flash.now[:notice] = @response_orders["openOrders"]["errMsg"]
        end
        #End of checking whether errCode variable from response 2
        #if response from webservice is null
      else
        flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
      end
      #End of checking whether response from webservice is not null
      render :index
    end
    #End of checking whether search by value is "all"
  end

  ##
  # This action is to show invoice detail page,
  # Based on invoice number
  # This page is only authorized to userlevel greater than 4
  ##
  def invoice_display
    #checking whether user can access invoice_display action
    unless can?("<","4")
      invoice_number = params[:id]
      @response_invoice_record_for_popup = invoke_webservice method: 'get', action: 'invoiceRecord', query_string: { invNo: invoice_number}
      #checking whether response from webservice is not null
      if @response_invoice_record_for_popup
        #checking whether errCode variable from response other than "0"
        if @response_invoice_record_for_popup.first["errCode"] != "0"
          flash.now[:alert] = @response_invoice_record_for_popup.first["errMsg"]
        end
        po_lines = @response_invoice_record_for_popup.first["poLine"]
        misc_lines = @response_invoice_record_for_popup.first["miscLines"]
        invoice_date =  Date.strptime(po_lines[1], "%m/%d/%y") rescue false
        ship_date = Date.strptime(misc_lines[1], "%m/%d/%y") rescue false
        klx_date = Date.new(2015,1,1)
        if invoice_date && invoice_date < klx_date
          @old_be_logo = 1
        elsif ship_date && ship_date < klx_date
          @old_be_logo = 1
        end
        #End of checking whether errCode variable from response other than "0"
        #if response from webservice is null
      else
        flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
      end
      #End of checking whether response from webservice is not null
      render :layout => "invoice"
      #If user cannot access invoice_display action
    else
      redirect_to :back
    end
    #End of checking whether user can access this action
  end

  ##
  # This action is to validate form search values,
  # If search by value is other than "all", then search by value should be entered
  # otherwise it will throw validation error
  ##
  def validate_values
    @days_format = OpenOrder.get_select_values
    @search_by_values = OpenOrder.get_search_values
    #checking whether search for(textbox) value is empty string and search by(select box) value is other than "all"
    if params[:search_for].blank? && params[:search_by] != "all"
      flash.now[:alert] =  I18n.translate("error",:scope => "open_orders.validate_values")
      render :index
    end
    #End of checking whether search for(textbox) value is empty string and search by(select box) value is other than "all"
  end

  def routing_error
    message_hash = {:request => request.env["REQUEST_URI"], :user => session[:user_name], :message =>  "404 !! The requested page does not exist."}
    rescue_no_route(message_hash)
  end

end
