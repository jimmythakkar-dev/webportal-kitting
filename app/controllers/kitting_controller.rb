#class KittingController < ApplicationController
#  before_filter :get_menu_id
#  def index
#  end
#
#  def new
#		if can?(:>, "2")
#
#		else
#			redirect_to unauthorized_url
#		end
#	end
#
#  # test kit history id , if so, display the kit history for that id else display latest kit
#  # get the shipTo data
#  def show
#    if params[:KitHistId]
#      @kitting_response = invoke_webservice method: 'get', action: 'kitting',
#                                          query_string: {action: "HI",
#                                          kitHistId: params[:KitHistId] }
#    else
#      @kitting_response = invoke_webservice method: 'get', action: 'kitting',
#                                          query_string: {action: "I",
#                                          custNo: current_user,
#                                          kitNo: params[:id] }
#    end
#    @shipTo_response  = invoke_webservice method: 'get', class: 'custInv/',
#                                          action: 'shipTo', query_string: {
#                                          custNo: current_user }
#  end
#
#  def edit
#		if can?(:>, "2")
#		@kitting_response = invoke_webservice method: 'get', action: 'kitting',
#                                          query_string: {action: "I",
#                                          custNo: current_user,
#                                          kitNo: params[:id] }
#    @shipTo_response  = invoke_webservice method: 'get', class: 'custInv/',
#                                          action: 'shipTo', query_string: {
#                                          custNo: current_user }
#		else
#			redirect_to unauthorized_url
#		end
#
#  end
#
#  def search
#    params[:page] = params[:page].nil? ? 1 : params[:page]
#    @kitting_response = invoke_webservice method: 'get', action: 'kitting',
#                                          query_string: {action: params[:kit_search_type],
#                                          custNo: current_user,
#                                          kitStatuses: params[:kit_status].join(","),
#                                          kitNo: params[:kit_number_search].try(:strip).try(:upcase),
#                                          page: params[:page].to_s }
#
#    if @kitting_response
#      if @kitting_response["errCode"] == "0"
#        @total_records = @kitting_response["totalRecords"].to_i
#        @total_page = Kitting.divide_records_in_pages @total_records
#        render "search_result"
#      else
#        flash.now[:alert] = @kitting_response["errMsg"]
#        render 'search_result'
#      end
#    else
#      flash.now[:notice] = "Service temporary unavailable"
#      render "index"
#    end
#  end
#
#  # setting data for creating kit
#  # test success, send email with that particular data
#  # test error,display kit new_err page with all the params
#  # error = 4 for duplicate kit number
#  # for email body use update_info page and render it over here
#  def create
#    # test if kit contain no part
#    if params[:kit_part_number].values.join().blank?
#      flash.now[:error] = "No Parts - Please enter part number and quantity"
#      render 'new_err'
#    else
#
#      @response = invoke_webservice method: 'post',action: 'kitting',
#                  data: {
#                    action:   "N" ,
#                    custNo:   current_user,
#                    user:     session[:user_name],
#                    kitNo:    params[:kit_number].upcase,
#                    kitDesc:  params[:kit_description],
#                    kitStatus:params[:kit_status],
#                    kitLoc:   params[:kit_location],
#                    kitNotes: params[:kit_Notes].values,
#                    partNo:   params[:kit_part_number].values,
#                    um:       params[:um].values,
#                    misc1:    params[:kit_tray].values,
#                    qty:      params[:kit_quantity].values,
#                    misc2:    params[:bin_number].values,
#                    kitVer:   "001"
#                  }
#      if @response
#        # test success than display newer kit with message of updated/create kit with action = NK
#        if @response["errCode"] == "0"
#          email_body = render_to_string "_update_info", layout: false
#          @line_station_update_email = invoke_webservice method: 'post', class: 'custInv/',
#                                                         action: 'lineStationUpdateEmail',data: {
#                                                         action:    "7",custNo:    current_user,
#                                                         emailBody: email_body,
#                                                         subject:   "Kit Action Request"
#            }
#          if @line_station_update_email
#            if @line_station_update_email["errMsg"] && @line_station_update_email["errMsg"].blank?
#              redirect_to kitting_path(CGI.escape(params[:kit_number]),:id => CGI.escape(params[:kit_number]), :actin => "NK")
#            else
#              flash.now[:alert] = @line_station_update_email["errMsg"]
#              render 'new_err'
#            end
#          end
#        else
#          flash.now[:error]   = @response["errMsg"]
#          @shipTo_response    = invoke_webservice method: 'get', class: 'custInv/',
#                                                  action: 'shipTo', query_string: { custNo: current_user }
#          part_count_arr      = params[:kit_part_number].values
#          part_count_arr.delete("")
#          params[:part_count] = part_count_arr.size
#          render 'new_err'
#        end
#			else
#        flash[:error] = "Service temporary unavailable"
#				redirect_to :back
#      end
#    end
#  end
#
#  # setting data for updating kit
#  # test success, send email with that particular data
#  # for email body use update_info page and render it
#  def update
#
#    if params[:kit_part_number].values.join().blank?
#      flash.now[:error] = "No Parts - Please enter part number and quantity"
#      render 'new'
#    else
#      @response = invoke_webservice method: 'post',action: 'kitting',
#                  data: {
#                    action:   "M",
#                    custNo:   current_user,
#                    user:     session[:user_name],
#                    kitNo:    params[:kit_number].upcase,
#                    kitDesc:  params[:kit_description],
#                    kitStatus:params[:kit_status],
#                    kitLoc:   params[:kit_location],
#                    kitNotes: params[:kit_Notes].values,
#                    partNo:   params[:kit_part_number].values,
#                    um:       params[:um].values,
#                    misc1:    params[:kit_tray].values,
#                    qty:      params[:kit_quantity].values,
#                    misc2:    params[:bin_number].values,
#                    kitVer:   "001"
#                  }
#
#      if @response
#
#        # test success than display newer kit with message of updated/create kit with action = NK
#        if @response["errCode"] == "0"
#          email_body = render_to_string "_update_info", layout: false
#          @line_station_update_email = invoke_webservice method: 'post', class: 'custInv/',
#                                                         action: 'lineStationUpdateEmail',
#                                                         data: { action:    "7",custNo:    current_user,
#                                                         emailBody: email_body,
#                                                         subject:   "Kit Action Request" }
#          if @line_station_update_email
#            if @line_station_update_email["errMsg"] && @line_station_update_email["errMsg"].blank?
#              redirect_to kitting_path(CGI.escape(params[:kit_number]),:id => CGI.escape(params[:kit_number]), :actin => "NK")
#            else
#              flash.now[:alert] = @line_station_update_email["errMsg"]
#              redirect_to edit_kitting_path(CGI.escape(params[:kit_number]),:id => CGI.escape(params[:kit_number]), :actin => "NK")
#            end
#          end
#        else
#          flash.now[:error]   = @response["errMsg"]
#          @kitting_response   = invoke_webservice method: 'get', action: 'kitting',
#                                                  query_string: {action: "I", custNo: current_user,
#                                                  kitNo: params[:id] }
#          @shipTo_response    = invoke_webservice method: 'get', class: 'custInv/',
#                                                  action: 'shipTo', query_string: { custNo: current_user }
#          params[:part_count] = params[:kit_part_number].size
#          render 'edit'
#        end
#      else
#        flash.now[:notice] = "Service temporary unavailable"
#      end
#    end
#  end
#
#  # display the history of that particular kit
#  def history
#    @kitting_response = invoke_webservice method: 'get', action: 'kitting',
#                                          query_string: {action: "H", custNo: current_user,
#                                          kitNo: params[:id] }
#    if @kitting_response
#      render 'history'
#    else
#      flash.now[:alert] = 'Service temporary unavailable'
#      render "new"
#    end
#	end
#
#end
