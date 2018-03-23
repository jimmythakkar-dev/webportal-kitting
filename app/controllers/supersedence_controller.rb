class SupersedenceController < ApplicationController
  before_filter :get_menu_id
  ##
    # This action is of index page (front page when someone
    #   clicked on Supersedence link)
  ##
  def index
  end

  ##
    # This action is to show supersedence search result page,
    #   based on value entered on search box
  ##
  def search
    part_number = params["txt_part_number"].try(:strip).try(:upcase)
    @response_supersedence = invoke_webservice method: 'get', class: 'custInv/',
                               action: 'superSedenceSearch',
                               query_string: { custNo: current_user,
                               partNo: part_number}
      if @response_supersedence
        if @response_supersedence["errCode"] == "1"
          flash[:notice] = @response_supersedence["errMsg"]
        end
      else
        flash[:notice] = I18n.translate("Service temporary unavailable",:scope => "rma.error")
      end
    render :index
  end
end
