class CriticalWatchController < ApplicationController
  before_filter :get_menu_id
  before_filter :add_headers, :only=>[:download]

  ##
    # This action is of index page (front page when someone
    #   clicked on Critical & Watch link)
    # Showing critical watch list as per current user
    #   (used default @building_list and @show_list object)
  ##
  def index
    @building_list = CriticalWatch.get_building_list
    @show_list = CriticalWatch.get_show_list
    @response_critical_watch = invoke_webservice method: 'get', class: 'custInv/',
                                                 action: 'criticalWatchAction',
                                                 query_string: { custNo: current_user, action: "H" }
    if @response_critical_watch
      if @response_critical_watch[0]["errCode"] == "1"
        flash.now[:notice] = @response_critical_watch[0]["errMsg"]
      end
    else
      flash.now[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render :index
  end

  ##
    # This action is to show critical watch detail page,
    #  based on selected id
  ##
  def show
    @sel_id = CriticalWatch.get_sel_id params[:id]
    @response_critical_watch_detail = invoke_webservice method: 'get', class: 'custInv/',
                                                        action: 'criticalWatchAction',
                                                        query_string: { custNo: current_user,
                                                                        action: "I",
                                                                        selId: @sel_id }
    if @response_critical_watch_detail
      if @response_critical_watch_detail[0]["errCode"] != ""
        flash.now[:notice] = @response_critical_watch_detail[0]["errMsg"]
      end
    else
      flash.now[:notice] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render :show
  end

  ##
    # This action is to initialize form values for create action,
    #  (used default @initial_status, @status, @line_responsible, @building and @location_program object)
  ##
  def new
    @initial_status = CriticalWatch.get_initial_status_values
    @status = CriticalWatch.get_status_values
    @line_responsible = CriticalWatch.get_line_resp_values
    @building = CriticalWatch.get_building_values
    @location_program = CriticalWatch.get_location_program_values
  end

  ##
    # This action is used to add new critical watch
    #  By sending selected form values to webservice
  ##
  def create
    @update_item_note = params[:update_item_note].gsub("\r","<BR/>")
    @update_item_note = @update_item_note.gsub("\n","")
    @response_create_critical_watch = invoke_webservice method: 'post',
                                                        class: 'custInv/', action: 'criticalWatchAction',
                                                        data: { custNo: current_user,
                                                                action: "N",
                                                                status: params[:status],
                                                                lineResp: params[:line_responsible],
                                                                contactInfo: params[:contact_information],
                                                                partNo: params[:part_number].try(:upcase).split(','),
                                                                supplier: params[:supplier],
                                                                manufacturer: params[:manufacturer],
                                                                subCoverage: params[:substitution_coverage],
                                                                program: params[:program],
                                                                aircraftSection: params[:aircraft_section],
                                                                lineStation: params[:line_station],
                                                                location: params[:location],
                                                                building: params[:building],
                                                                needDate: params[:need_date],
                                                                promiseDate: params[:promise_on_dock],
                                                                daysSlipped: params[:days_slipped],
                                                                impactDate: params[:impact_date],
                                                                firstPOQty: params[:first_po_quantity],
                                                                qtyDueIn: params[:quantity_due_in],
                                                                minNeedQty: params[:minimum_need_quantity],
                                                                releaseQty: params[:release_quantity],
                                                                gapPOQty: params[:gap_quantity],
                                                                gapPODate: params[:gap_date],
                                                                gapPONum: params[:gap_po_number],
                                                                gapPOTrackNum: params[:gap_tracking_number],
                                                                linesAffected: params[:lines_affected],
                                                                rootCause: params[:root_cause],
                                                                correctiveAction: params[:corrective_action],
                                                                comments: params[:comments],
                                                                oldComments: params[:old_comments],
                                                                updateItemStatus: params[:update_item_status].split(","),
                                                                updateItemNote: @update_item_note.split(",")
                                                        }
    if @response_create_critical_watch
      if @response_create_critical_watch["errCode"] != ""
        flash.now[:notice] = @response_create_critical_watch["errMsg"]
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    redirect_to critical_watch_index_path
  end

   ##
    # This action is used to populate form values from existing data through webservice for update action
    #  (used default @initial_status, @status, @line_responsible, @building object)
  ##
  def edit
    @initial_status = CriticalWatch.get_initial_status_values
    @status = CriticalWatch.get_status_values
    @line_responsible = CriticalWatch.get_line_resp_values
    @building = CriticalWatch.get_building_values
    @sel_id = CriticalWatch.get_sel_id params[:id]
    @response_critical_watch_edit_detail = invoke_webservice method: 'get', class: 'custInv/',
                                                             action: 'criticalWatchAction',
                                                             query_string: { custNo: current_user,
                                                                             action: "I",
                                                                             selId: @sel_id }
    if @response_critical_watch_edit_detail
      if @response_critical_watch_edit_detail[0]["errCode"] != ""
        flash.now[:notice] = @response_critical_watch_edit_detail[0]["errMsg"]
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render :edit
  end

  ##
    # This action is used to update an existing critical watch
    #  By sending selected form values to webservice
  ##
  def update
    @sel_id = CriticalWatch.get_sel_id params[:id]
    @update_item_note = params[:update_item_note].gsub("\r","<BR/>")
    @update_item_note = @update_item_note.gsub("\n","")
    @update_new_item_note = params[:original_update_item_note].push(@update_item_note)
    @update_new_item_status = params[:original_update_item_status].push(params[:update_item_status])
    @response_update_critical_watch = invoke_webservice method: 'post',
                                                        class: 'custInv/', action: 'criticalWatchAction',
                                                        data: { custNo: current_user,
                                                                action: "U",
                                                                selId: @sel_id,
                                                                status: params[:status],
                                                                lineResp: params[:line_responsible],
                                                                contactInfo: params[:contact_information],
                                                                partNo: params[:part_number].try(:upcase).split(','),
                                                                supplier: params[:supplier],
                                                                manufacturer: params[:manufacturer],
                                                                subCoverage: params[:substitution_coverage],
                                                                program: params[:program],
                                                                aircraftSection: params[:aircraft_section],
                                                                lineStation: params[:line_station],
                                                                location: params[:location],
                                                                building: params[:building],
                                                                needDate: params[:need_date],
                                                                promiseDate: params[:promise_on_dock],
                                                                daysSlipped: params[:days_slipped],
                                                                impactDate: params[:impact_date],
                                                                firstPOQty: params[:first_po_quantity],
                                                                qtyDueIn: params[:quantity_due_in],
                                                                minNeedQty: params[:minimum_need_quantity],
                                                                releaseQty: params[:release_quantity],
                                                                gapPOQty: params[:gap_quantity],
                                                                gapPODate: params[:gap_date],
                                                                gapPONum: params[:gap_po_number],
                                                                gapPOTrackNum: params[:gap_tracking_number],
                                                                linesAffected: params[:lines_affected],
                                                                rootCause: params[:root_cause],
                                                                correctiveAction: params[:corrective_action],
                                                                comments: params[:comments],
                                                                oldComments: params[:old_comments],
                                                                updateItemStatus: @update_new_item_status,
                                                                updateItemNote: @update_new_item_note,
                                                                updateItemDate: params[:original_update_item_date].split(","),
                                                                updateItemBy: params[:original_update_item_by].split(",")
                                                        }
    if @response_update_critical_watch
      if @response_update_critical_watch["errCode"] != ""
        flash.now[:notice] = @response_update_critical_watch["errMsg"]
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    redirect_to critical_watch_path(@response_update_critical_watch["updatedID"],:history_id => 0)
  end

  ##
    # This action is used to view the history of selected critical watch
    #   based on selected id
  ##
  def view_history
    if params[:id]
      @sel_id = CriticalWatch.get_sel_id params[:id]
      @case_Id = @sel_id.split("!")[2]
    else
      @case_Id = 5
    end
    @response_critical_watch_history = invoke_webservice method: 'get', class: 'custInv/',
                                                         action: 'criticalWatchAction',
                                                         query_string: { action: "CH",
                                                                         caseId: @case_Id }
    if @response_critical_watch_history
      @response_critical_watch_history_item_details = []
      if @response_critical_watch_history[0]["errCode"] != ""
        flash.now[:notice] = @response_critical_watch_history[0]["errMsg"]
      else
        unless @response_critical_watch_history[0]["caseList"].blank?
          @response_critical_watch_history[0]["idlist"].each do |caseId|
            @response_history_item_details = invoke_webservice method: 'get', class: 'custInv/',
                                                               action: 'criticalWatchAction',
                                                               query_string: { custNo: current_user, action: "I",
                                                                               selId: caseId.first }
            @response_critical_watch_history_item_details << @response_history_item_details
          end
        end
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
    render :view_history
  end

  ##
    # This action is used to create xls file for critical watch list,
    #   and download the xls file
  ##
  def download
    @building_list = CriticalWatch.get_building_list
    @show_list = CriticalWatch.get_show_list
    @response_ship_to = invoke_webservice method: 'get', class: 'custInv/',
                                          action: 'shipTo',
                                          query_string: { custNo: current_user }
    if @response_ship_to
      if @response_ship_to["errCode"] != ""
        flash.now[:notice] = @response_ship_to["errMsg"]
      else
        flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
      end
    end
    @response_critical_watch = invoke_webservice method: 'get', class: 'custInv/',
                                                 action: 'criticalWatchAction',
                                                 query_string: { custNo: current_user, action: "H"}
    if @response_critical_watch
      if @response_critical_watch[0]["errCode"] == "1"
        flash.now[:notice] = I18n.translate("no_critical_cases",:scope => "critical_watch.index") + "."
        render :index
      else
        # code to create xls file
        workbook = WriteExcel.new(Rails.public_path+"/excel/critical_watch/excel_list_out.xls")
        binlocations  = workbook.add_worksheet
        format = workbook.add_format(:bold => 1, :color => 'black', :align => 'left', :bottom => 2)
        format1 = workbook.add_format
        format2 = workbook.add_format(:bold => 1, :size => 11)
        format1.set_align('vjustify')
        workbook.set_custom_color(40, '#ff8b8b')
        format3 = workbook.add_format(:bg_color => 40)
        format4 = workbook.add_format(:color => 'red')
        @response_ship_to["shipTo"].split('<BR>').each_with_index do |value, index_value|
          if value != ""
            binlocations.write(index_value, 0, value, format2)
          end
        end
        @row_value = @response_ship_to["shipTo"].split('<BR>').size
        # create a table in xls file
        binlocations.write(@row_value+1, 0)
        binlocations.write(@row_value+2, 0)
        binlocations.write(@row_value+3, 0,"CRITICAL / WATCH SUMMARY: ", format2)
        binlocations.write(@row_value+3, 1,"#{session[:customer_Name]}", format4)
        binlocations.set_column('A:A', 35)
        binlocations.write(@row_value+5, 0,I18n.translate("case",:scope => "critical_watch.index"), format)
        binlocations.write(@row_value+5, 1,I18n.translate("part_num",:scope => "open_orders._open_order"), format)
        binlocations.write(@row_value+5, 2,I18n.translate("DATE",:scope => "critical_watch.edit"), format)
        binlocations.write(@row_value+5, 3,I18n.translate("status",:scope => "critical_watch.new"), format)
        binlocations.write(@row_value+5, 4,"Resp.", format)
        binlocations.write(@row_value+5, 5,I18n.translate("location",:scope => "critical_watch.new"), format)
        binlocations.write(@row_value+5, 6,I18n.translate("program",:scope => "critical_watch.new"), format)
        binlocations.write(@row_value+5, 7,I18n.translate("line_station",:scope => "critical_watch.index"), format)
        binlocations.write(@row_value+5, 8,I18n.translate("supplier",:scope => "critical_watch.index"), format)
        binlocations.write(@row_value+5, 9,I18n.translate("min_need",:scope => "critical_watch.index"), format)
        binlocations.write(@row_value+5, 10,I18n.translate("promise_date",:scope => "critical_watch.index"), format)
        binlocations.write(@row_value+5, 11,I18n.translate("NOTES",:scope => "panstock_requests._edit_panstock"), format)
        index_of_row = 0
        @response_critical_watch[0]["caseList"].each_index do |index|
          binlocations.write(@row_value+6+index_of_row, 0,@response_critical_watch[0]["caseList"][index])
          binlocations.write(@row_value+6+index_of_row, 1,@response_critical_watch[0]["partNoList"][index])
          binlocations.set_column(@row_value+6+index_of_row, 1, 20)
          binlocations.write(@row_value+6+index_of_row, 2,@response_critical_watch[0]["dateList"][index])
          binlocations.write(@row_value+6+index_of_row, 3,@response_critical_watch[0]["statusList"][index])
          binlocations.write(@row_value+6+index_of_row, 4,@response_critical_watch[0]["lineRespList"][index])
          binlocations.write(@row_value+6+index_of_row, 5,@response_critical_watch[0]["locationList"][index])
          binlocations.write(@row_value+6+index_of_row, 6,@response_critical_watch[0]["programList"][index])
          binlocations.write(@row_value+6+index_of_row, 7,@response_critical_watch[0]["lineStationList"][index])
          binlocations.write(@row_value+6+index_of_row, 8,@response_critical_watch[0]["supplierList"][index])
          binlocations.write(@row_value+6+index_of_row, 9,@response_critical_watch[0]["minNeedQtyList"][index])
          unless @response_critical_watch[0]["promiseDateList"][index] == "" || @response_critical_watch[0]["promiseDateList"][index] == nil
            if Date.today > Date.strptime(@response_critical_watch[0]["promiseDateList"][index],"%m/%d/%y")
              binlocations.write(@row_value+6+index_of_row, 10,@response_critical_watch[0]["promiseDateList"][index])
            else
              binlocations.write(@row_value+6+index_of_row, 10,@response_critical_watch[0]["promiseDateList"][index], format3)
            end
          end
          @result_notes = ""
          @response_critical_watch[index+1]["updateItemNote"].each_index do |index_of_notes|
            unless @response_critical_watch[index+1]["updateItemNote"][index_of_notes] == ""
              update_item_date_formatted = Date.strptime(@response_critical_watch[index+1]["updateItemDate"][index_of_notes], "%m/%d/%Y").strftime("%m/%d/%y")
              @result_notes << "[" + update_item_date_formatted + " - " + @response_critical_watch[index+1]["updateItemStatus"][index_of_notes] + "] - " + @response_critical_watch[index+1]["updateItemNote"][index_of_notes] + "\n"
            end
          end
          binlocations.write(@row_value+6+index_of_row, 11, @result_notes)
          binlocations.set_row(@row_value+6+index_of_row, 60)
          index_of_row += 1
        end
        workbook.close
        send_file Rails.public_path+"/excel/critical_watch/excel_list_out.xls", :disposition => "attachment"
      end
    else
      flash.now[:alert] = I18n.translate("service_unavailable",:scope => "rma.error")
    end
  end
end