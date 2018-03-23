class WebOrderRequestController < ApplicationController
  # WEB ORDER CONTROLLER FOR SIKORSKY AND VARIABLE BIN QUANTITY
  before_filter -> { get_menu_id params }
  # INDEX ACTION TO FETCH OATS/SHIP TO FOR POPULATING IN FORM
  def index
    if params[:web_order_type]=="Sikorsky"
      @sikorsky_order_type = true
      @sikorsky_web_order = invoke_webservice method: 'get',action: 'checkNYFWebOrder', query_string: { custNo: current_user, actionFlag: "Order Form" }
      if @sikorsky_web_order && @sikorsky_web_order["errMsg"]==""
        @ship_to = @sikorsky_web_order["locations"]
        @oat = @sikorsky_web_order["oats"].split(",")
      else
        @error = true
        flash[:error]= @sikorsky_web_order.present? ? @sikorsky_web_order["errMsg"] : "Service Temporarily Unavailable"
      end
    else
      @sikorsky_order_type = false
      @variable_quantity_bin_order = invoke_webservice method: 'get',action: 'shipToInfo', query_string: { custNo: current_user, infoFlag: "GETADDRS" }
      if @variable_quantity_bin_order && @variable_quantity_bin_order["errMsg"] == ""
        @ship_to = @variable_quantity_bin_order["getAddrs_acctNos"].join(",").split(",").zip(@variable_quantity_bin_order["cityStates"].join(",").split(",")).map { |object| object.join("-") }
      else
        @error = true
        flash[:error]= @variable_quantity_bin_order.present? ? @variable_quantity_bin_order["errMsg"] : "Service Temporarily Unavailbale"
      end
    end
  end
  # PROCESS FORM DATA AND SENDS TO CARDEX FOR ORDER PLACEMENT
  def process_form
    if params[:web_order_type].present? && params[:web_order_type] == "Sikorsky"
      if params[:oat].is_a?(Array)
        @sikorsky_order_type = true
        # builds query param for posting data to cardex
        query_param = {
            custEmail: params[:email],
            userComments: params[:additional_comments],
            custName: params[:name],
            compName: params[:company],
            userName: session["customer_Name"],
            password: "URneed",
            buyerID: params[:buyer_id],
            custPN: params[:part_number].reject(&:blank?).join(","),
            custQty: params[:quantity].reject(&:blank?).join(","),
            custUM: params[:uom][0..(params[:part_number].reject(&:blank?).length)-1].join(","),
            custDelivery: params[:deliver_to].reject(&:blank?).join(","),
            shipto: params[:ship_to],
            oats: params[:oat].reject(&:blank?).join(","),
            actionFlag: 'Results'
        }
        @result = invoke_webservice method: 'post',action: 'checkNYFWebOrder', data: query_param
        if @result.nil?
          flash[:error] = "Service temporarily unavailable."
          redirect_to :back
        else
          respond_to do |format|
            format.html {}
          end
        end
      else
        flash[:error]= error_message
        redirect_to :back
      end
    elsif params[:web_order_type].present? && params[:web_order_type] == "Variable Quantity Bin Order"
      @sikorsky_order_type = false
      # builds query param for posting data to cardex
      query_param = {
          custEmail:params[:email],
          userComments: params[:additional_comments],
          custName: params[:name],
          compName: params[:company],
          userName: session["customer_Name"],
          buyerID: params[:buyer_id],
          custPN: params[:part_number].reject(&:blank?).join(","),
          custQty: params[:quantity].reject(&:blank?).join(","),
          custUM: params[:uom][0..(params[:part_number].reject(&:blank?).length)-1].join(","),
          custDelivery: params[:deliver_to].reject(&:blank?).join(","),
          shipto: params[:ship_to],
          custNo: current_user,
          actionFlag: "Results"
      }
      @result = invoke_webservice method: 'post', action: 'checkWebOrder',data: query_param
      if @result.nil?
        flash[:error] = "Service temporarily unavailable."
        redirect_to :back
      else
        respond_to do |format|
          format.html {}
        end
      end
    else
      flash[:error]= error_message
      redirect_to :back
    end
  end

  private
  # RETURNS ERROR MESSAGE WHEN URL IS TAMPERED
  def error_message
    "Your order cannot be processed, you would have mistyped the details . Retry Order"
  end

end
