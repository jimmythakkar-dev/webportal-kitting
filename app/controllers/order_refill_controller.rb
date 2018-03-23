class OrderRefillController < ApplicationController
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
    @days_format = OrderRefill.get_select_values
    #default values for search by values to be rendered in view
    @search_by_values = OrderRefill.get_search_values
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
    @days_format = OrderRefill.get_select_values
    #default values for search by values to be rendered in view
    @search_by_values = OrderRefill.get_search_values
    #checking whether search by value is "all"
    if params[:search_by_refill].include? "all"
      # ITR: Threading of “All Refill Orders” request
      # Creating a Thread to Send mail in Background Process.
      thread = Thread.new { invoke_webservice method: 'post', action: 'openOrders', data: { custNo: current_user,custEm: session[:buyer_email],stFlag: "XO"} }
      at_exit { thread.join }
      @response_send_refill_order = thread.status
      flash.now[:notice] = I18n.translate("mail_msg",:name => session[:buyer_email],:scope => "order_refill.search")
      render :index
      #if search by value is other than "all"
    else
      search_for = params[:search_for_refill].try(:strip).try(:upcase)
      search_by = params[:search_by_refill]
      search_start_date = (Time.now - params[:start_date_refill].to_i.days).strftime("%m/%d/%Y")
      search_end_date = Time.now.strftime("%m/%d/%Y")
      if params[:page].nil?
        params[:page] = 1
      end
      if search_by == "pn"
        @response_part_nums = invoke_webservice method: 'get',class: 'custInv/', action: 'partNums', query_string: { custNo: current_user, partNo: search_for }   #checking whether response from webservice is not null
        if @response_part_nums
          @partScan = 0
          #checking whether errMsg variable from response
          if @response_part_nums["errMsg"] != ""
            flash.now[:notice] = @response_part_nums["errMsg"]
          elsif @response_part_nums["searchPartList"].first.blank?
            if @response_part_nums["scancodeList"].include? search_for
              @partScan = 1
            end
            if @partScan == 0
              @inv_part_number = @response_part_nums["invPNList"].first unless @response_part_nums["invPNList"].first.blank?
            elsif @partScan == 1
              index_of_scancode = @response_part_nums["scancodeList"].index(search_for)
              @inv_part_number = @response_part_nums["scancodeList"].values_at(index_of_scancode).join
            end
            if @inv_part_number
              part_number = @inv_part_number
            else
              part_number = search_for
            end
            @response_refill_order = invoke_webservice method: 'get', action: 'srchRefillOrdersShipped', query_string: { custNo: current_user, srch:  part_number, srchBy: search_by, srcBdt: search_start_date, srcEdt: search_end_date }
            #checking whether response from webservice is not null
            if @response_refill_order
              #checking whether errMsg variable from response
              if @response_refill_order["errMsg"] != ""
                flash.now[:notice] = @response_refill_order["errMsg"]
              else
                @response_list = OrderRefill.sort_record(@response_refill_order)
                @length = @response_list.length
                @result = @response_list.keys.paginate(params[:page],100)
              end
              #End of checking whether errMsg variable from response
              #if response from webservice is null
            else
              flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
            end
            #End of checking whether response from webservice is not null
          end
          #End of checking whether errMsg variable from response
          #if response from webservice is null
        else
          flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
        #End of checking whether response from webservice is not null
      elsif search_by == "po"
        @response_refill_order = invoke_webservice method: 'get', action: 'srchRefillOrdersShipped', query_string: { custNo: current_user, srch:  search_for, srchBy: search_by, srcBdt: search_start_date, srcEdt: search_end_date }
        #checking whether response from webservice is not null
        if @response_refill_order
          #checking whether errMsg variable from response
          if @response_refill_order["errMsg"] != ""
            flash.now[:notice] = @response_refill_order["errMsg"]
          else
            @response_list = OrderRefill.sort_record(@response_refill_order)
            @length = @response_list.length
            @result = @response_list.keys.paginate(params[:page],100)
          end
          #End of checking whether errMsg variable from response
          #if response from webservice is null
        else
          flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
        end
        #End of checking whether response from webservice is not null
      end
      render :index
    end
    #End of checking whether search by value is "all"
  end


  ##
  # This action is to validate form search values,
  # If search by value is other than "all", then search by value should be entered
  # otherwise it will throw validation error
  ##
  def validate_values
    @days_format = OrderRefill.get_select_values
    @search_by_values = OrderRefill.get_search_values
    #checking whether search for(textbox) value is empty string and search by(select box) value is other than "all"
    if params[:search_for_refill].blank? && params[:search_by_refill] != "all"
      flash.now[:alert] =  I18n.translate("error",:scope => "open_orders.validate_values")
      render :index
    end
    #End of checking whether search for(textbox) value is empty string and search by(select box) value is other than "all"
  end
end
