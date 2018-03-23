class MinMaxReportsController < ApplicationController
  before_filter :get_menu_id

  ##
    # This action is of index page
  ##
  def index
    if params[:send_order]
      @response_send_reports = invoke_webservice method: 'get', action: 'minMaxReport',
                                           query_string: { vendorNo: session[:vendor_number],
                                                           email:  session[:buyer_email]
                                           }
    #checking whether response from webservice is not null
      if @response_send_reports
       #checking whether errCode variable from response not equal to 0
        if @response_send_reports["errCode"] != "0"
          flash.now[:notice] = "<div class='alert alert-danger' role='alert'>#{@response_send_reports['errMsg']}</div>".html_safe
        else
          flash.now[:notice] = "<div class='alert alert-success' role='alert'>#{@response_send_reports['errMsg']}</div>".html_safe
        end
        #End of checking whether errCode variable from response not equal to 0
     #if response from webservice is null
      else
        flash.now[:notice] = "<div class='alert alert-danger'>#{I18n.translate("service_unavailable",:scope => "rma.error")}</div>".html_safe
      end
     #End of checking whether response from webservice is not null
    end
  end
end
