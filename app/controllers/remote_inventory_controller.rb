class RemoteInventoryController < ApplicationController
  before_filter :get_menu_id
#  before_filter :destroy_session, :only => [:search]
  def index
    @response_cust_inv = invoke_webservice method: 'get', class: 'custInv/',action:'binAccounts',query_string: { custNo: current_user, userType: current_customer.user_type }
    @@response_cust_inv =  @response_cust_inv
    if @response_cust_inv.present? && @response_cust_inv["errMsg"].blank?
      @response_cust_inv["binAccounts"] = current_user if @response_cust_inv["binAccounts"].blank?
    else
      @error = @response_cust_inv.present? ? @response_cust_inv["errMsg"] : "Service Temporarily Unavailable"
    end
  end

  def search
    @stock= Array.new
    @part_number = params[:part_number_inv].try(:upcase)
    @customer_number = params[:ship_to]
    params[:parts_to_restock] = params[:parts_to_restock].present? ? params[:parts_to_restock] : ""
    if params[:open_orders] && params[:open_orders] == "Open Orders"
      unless (defined? @@response_cust_inv).nil?
        @response_cust_inv =  @@response_cust_inv
      end
      @response_open_orders = invoke_webservice method: 'get', action:'sendOrder',query_string: { partNo: @part_number, custNo: @customer_number, locBin: params[:parts_to_restock] }
      if @response_open_orders
        if @response_open_orders["errCode"].blank?
          @error_open_orders = I18n.translate("open_orders_sent",:scope => "remote_inv.search")
        else
          @error_open_orders = @response_open_orders["errMsg"]
        end
      else
        @error_open_orders = I18n.translate("service_unavailable",:scope => "rma.error")
      end
      render :index
    else
      @response_get_bins = invoke_webservice method: 'get', class: 'custInv/', action:'bins', query_string: { partNo: @part_number, custNo: @customer_number }
      if @response_get_bins
        if @response_get_bins["errMsg"] != ""
          @error_get_bins = @response_get_bins["errMsg"]
        end
      else
        flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
      end
    end

    if params[:order_send_parts]
      if session[:order_flag] == "Y" && (params[:order_send_parts] = "Order" || params[:order_send_parts] = "Ordine") && !params[:parts_to_restock].blank?
        @response_orders = invoke_webservice method: 'get', action:'sendOrder',
                                             query_string: { partNo: @part_number,
                                                             custNo: @customer_number,
                                                             userLogin: session[:user_name],
                                                             locBin: params[:parts_to_restock] }
        if @response_orders
          if @response_orders["errCode"].blank?
            @error_orders = I18n.translate("orders_sent",:scope => "remote_inv.search")
          else
            @error_orders = @response_orders["errMsg"]
          end
        else
          @error_orders = I18n.translate("service_unavailable",:scope => "rma.error")
        end
        render :index
      end
    end
  end

  def search_async
    if request.xhr?
      @stock = params[:stock_val].split(",")
      @part_number = params[:part_number].try(:upcase)
      @response_get_bins = invoke_webservice method: 'get', class: 'custInv/', action:'bins', query_string: { partNo: @part_number, custNo: current_user }
      if @response_get_bins
        if @response_get_bins["errMsg"] != ""
          @error_get_bins = @response_get_bins["errMsg"]
        end
      else
        @error_get_bins = I18n.translate("service_unavailable",:scope => "rma.error")
      end
    end
  end
end