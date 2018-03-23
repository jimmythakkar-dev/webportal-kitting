class StockLookupController < ApplicationController
  before_filter :get_menu_id
  ##
    # This action is of index page (front page when someone
    #   clicked on Supersedence stock lookup)
  ##
  def index
  end

  ##
    # This action is to show supersedence search result page,
    #   based on value entered on search box
  ##
  def search
    part_number = params["txt_part_number"].try(:strip).try(:upcase)
    @page_action = params["read"]
    @response_stock_lookup = invoke_webservice method: 'get',
                               action: 'partsOnHand',
                               query_string: { partNo: part_number}

      if @response_stock_lookup
        if @response_stock_lookup["errCode"] == "1"
          flash[:notice] = @response_stock_lookup["errMsg"]
        end
      else
        flash[:notice] = I18n.translate("Service temporary unavailable",:scope => "rma.error")
      end
    render :index
  end
end
