require_dependency "kitting/application_controller"

module Kitting
  class KitCopiesController < ApplicationController
    layout "kitting/fit_to_compartment", :only => [ :print_label, :show, :pick_ticket ]
    before_filter :get_acess_right
    after_filter  :clean_pdf, only: :print_label
#    after_filter :delete_barcodes, :only => :pick_ticket_print
    include Kitting::KitCopiesHelper

##
# This action is of index page of kitcopies showing Kit Copies list as per user access
##
    def index
      # Showing only locations specific to the customer
      @location = Kitting::Location.where("customer_number = ? OR customer_number IS NULL",session[:customer_number])
      if can?(:>=, "4")
        active_kit_copies = []
        params[:kit_number_search] = params[:kit_number_search].try(:upcase).try(:strip)
        @checkKitOpenOrder = invoke_webservice method: 'post', action:'checkKitOpenOrder',data: {custNo: current_user, partNoList: []}
        if @checkKitOpenOrder.present?
          unless @checkKitOpenOrder["errCode"] == '0'
            @checkKitOpenOrder["partNoList"] = []
            flash.now[:notice] = @checkKitOpenOrder["errMsg"]
          end
          kits_in_order = Array.new
          @checkKitOpenOrder['partNoList'].in_groups_of(500) { |group|
            kits_in_order << Kitting::Kit.find_all_by_kit_number(group)
          }
          kits_in_order = kits_in_order.flatten
          @kit_copy_list = Array.new
          kits_in_order.each do |kit|
            @kit_copy_list <<  kit.kit_copies.map(&:kit_version_number)
            @kit_copy_list.flatten!
          end

          if params[:kit_number_search].present?
            @search = params[:kit_number_search].try(:upcase).try(:strip)
            if @search[-1] == "X" or @search[-1] == "Y" or @search[-1] == "Z"
              @code = rate params[:kit_number_search].try(:strip)[-1]
              @search = @search.chop + @code.to_s
            end
            if params[:kit_queue].present?
              if params[:kit_order_status] == "ALL"
                @kit_copies =  Kitting::KitCopy.where("kit_version_number LIKE ?  and customer_id IN (?) and location_id = ? ","%#{@search}%",current_company,params[:kit_queue])
              else
                if params[:kit_order_status] == "Y"
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    @kit_copies << Kitting::KitCopy.where("kit_version_number IN (?)  and customer_id IN (?) and location_id = ? and kit_version_number LIKE ? ",group,current_company,params[:kit_queue],"%#{@search}%")
                  }
                  @kit_copies = @kit_copies.flatten
                else
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    @kit_copies  << Kitting::KitCopy.where("kit_version_number NOT IN (?)  and customer_id IN (?) and location_id = ? and kit_version_number LIKE ? ",group,current_company,params[:kit_queue],"%#{@search}%")
                  }
                  @kit_copies = @kit_copies.flatten
                end
              end
            else
              if params[:kit_order_status] == "ALL" or params[:kit_order_status].nil?
                @kit_copies = Kitting::KitCopy.where("kit_version_number LIKE ?  and customer_id IN (?)  ","%#{@search}%",current_company)
              else
                if params[:kit_order_status] == "Y"
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    @kit_copies << Kitting::KitCopy.where("kit_version_number IN (?) and  customer_id IN (?) and kit_version_number LIKE ? ",group,current_company,"%#{@search}%")
                  }
                  @kit_copies = @kit_copies.flatten
                else
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    @kit_copies << Kitting::KitCopy.where("kit_version_number NOT IN (?) and  customer_id IN (?) and kit_version_number LIKE ? ",group,current_company,"%#{@search}%")
                  }
                  @kit_copies = @kit_copies.flatten
                end
              end
            end
          else
            if params[:kit_queue].present?
              if params[:kit_order_status] == "ALL"
                @kit_copies = Kitting::KitCopy.where(:location_id => params[:kit_queue],:customer_id => current_company )
              else
                if params[:kit_order_status] == "Y"
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    @kit_copies << Kitting::KitCopy.where("kit_version_number IN (?) and location_id = ? and customer_id IN (?) ",group,params[:kit_queue],current_company)
                  }
                  @kit_copies = @kit_copies.flatten
                else
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    if @kit_copies.empty?
                      @kit_copies << Kitting::KitCopy.where("kit_version_number NOT IN (?) and location_id = ? and customer_id IN (?) ",group,params[:kit_queue],current_company)
                    else
                      @kit_copies.flatten.reject! { |kc| group.include?(kc.kit_version_number) and current_company.include?(kc.customer_id) and kc.location_id == params[:kit_queue].to_i }
                    end
                  }
                  @kit_copies = @kit_copies.flatten
                end
              end
            else
              if params[:kit_order_status] == "ALL" or params[:kit_order_status].nil?
                @kit_copies = Kitting::KitCopy.where("customer_id IN (?) ",current_company)
              else
                if params[:kit_order_status] == "Y"
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(10) { |group|
                    @kit_copies << Kitting::KitCopy.where("kit_version_number IN (?) and customer_id IN (?) ",group,current_company)
                  }
                  @kit_copies = @kit_copies.flatten
                else
                  @kit_copies = Array.new
                  @kit_copy_list.in_groups_of(500) { |group|
                    if @kit_copies.empty?
                      @kit_copies  << Kitting::KitCopy.where("kit_version_number NOT IN (?) and customer_id IN (?) ",group,current_company)
                    else
                      @kit_copies.flatten.reject! { |kc| group.include?(kc.kit_version_number) and current_company.include?(kc.customer_id) }
                    end
                  }
                  @kit_copies = @kit_copies.flatten
                end
              end
            end
          end
          @kit_copies.each do |kit_copy|
            if kit_copy.status != 6 || (view_context.check_kit_filling(kit_copy) && view_context.get_filling_id(kit_copy).present?)
              active_kit_copies << kit_copy
            end
          end
          @kit_copies = active_kit_copies.sort.reverse.flatten.paginate(params[:page], 100)
        else
          flash.now[:notice] = @rbo_down = "Service Temporarily Unavailable"
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is the show page of a kit copy with print all and print selected buttons for calling the
# pick ticket print function.
##
    def pick_ticket
      if can?(:>=, "4")
        @kit_copies = Kitting::KitCopy.find_by_id(params[:id])
        kit_version = @kit_copies.kit.current_version if @kit_copies.kit.present?
        tracked_version = TrackCopyVersion.find_by_kit_copy_id(params[:id]).picked_version if TrackCopyVersion.find_by_kit_copy_id(params[:id]).present?
        if kit_version.present? and tracked_version.present?
          if kit_version.to_i != tracked_version.to_i
            @changed_kit_data = invoke_webservice method: "get", action: "kitDelta", query_string: {kitBomVersion: kit_version, kitCopyVersion: @kit_copies.version_status , kitNo: @kit_copies.kit.kit_number }
            changed_cups = []
            unless @changed_kit_data.first["errCode"].present?
              @changed_kit_data.each do |version|
                version["commonCupParts"].each do |common_cup|
                  diff = common_cup["previousQty"].to_i - common_cup["demand_quantity"].to_i
                  unless diff == 0
                    changed_cups << common_cup["cup_id"]
                  end
                end
                version["addedCupParts"].each do |add_cup|
                  changed_cups << add_cup["cup_id"]
                end
                version["deletedCupParts"].each do |del_cup|
                  changed_cups << del_cup["cup_id"]
                end
                @change_cup = changed_cups.uniq
              end
            end
            @alert = "The Kit BOM has been modified from previous fill."
          end
        end
        @media_type = @kit_copies.kit.kit_media_type
        @compartment_layout = @media_type.compartment_layout
        @cups = @kit_copies.kit.cups
        @cup_parts_found = @cups.map(&:cup_parts).flatten.count
        if @media_type.kit_type == "multi-media-type"
          @mmt_kit_copies = Kitting::Kit.where(:parent_kit_id => @kit_copies.kit.id, :commit_status => true,:commit_id => nil).order("id ASC") if @kit_copies.kit.present?
          @child_kit = params[:mmt_child_kit_id].present? ? @mmt_kit_copies.select { |kit| kit.id == params[:mmt_child_kit_id].to_i } : [@mmt_kit_copies.first]
          @cups = (get_commited_data.call @child_kit,"cups").flatten
          @cup_parts = get_commited_data.call @cups.flatten,"cup_parts"
          @cup_parts_found = @cup_parts.flatten.count
          @compartment_layout = @child_kit.first.kit_media_type.compartment_layout
        end
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = []
        if @binCenters_response
          @binCenters_response['binCenterList'].each do |i|
            @binCenters << i
          end
        end
        respond_to do |format|
          format.html
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is for printing the pick sheet of selected or all cups, it calls the pick ticket RBO call
# to send data regarding cup parts details to be printed to the RBO.
##
    def pick_ticket_print
      if can?(:>=, "4")
        if request.method == "POST"
          @kit_copies = Kitting::KitCopy.find_by_id(params[:kit_copy_id])
          @media_type = @kit_copies.kit.kit_media_type.kit_type
          if @kit_copies.blank?
            render :text => "<script type=\"text/javascript\">if (confirm('There is no record exists for this copy to print pick ticket.')){ window.close(); } </script>"
          else
            kit_version_number = @kit_copies.kit_version_number
            version_number = kit_version_number.split("-").last
            kit_number = @kit_copies.kit.kit_number
            description = @kit_copies.kit.description
            kit_media_type = @kit_copies.try(:kit).try(:kit_media_type).try(:name)
            kit_type = @kit_copies.try(:kit).try(:kit_media_type).try(:kit_type)
            if (params[:select_ids_for_alternate])
              params[:select_ids] = params[:select_ids_for_alternate].join(",").split(",")
            end
            @pick_ticket_print_details = invoke_webservice method: 'get', action: 'pickTicket',query_string: { kitNo: params[:kit_number].upcase,custNo: current_user, binCenter: params[:bincenter] }
            if @pick_ticket_print_details
              if @pick_ticket_print_details["errMsg"].present?
                render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@pick_ticket_print_details["errMsg"]}')){ window.close(); } </script>"
              else
                if params[:reprint].blank?
                  ##################### KIT FILLING FUNCTION START ###############################
                  @check_filling = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:kit_copy_id],1)
                  if @check_filling
                    @kit_filling = @check_filling
                  else
                    @kit_filling = {kit_copy_id: params[:kit_copy_id],flag: 1,created_by: current_user }
                    @kit_filling = current_customer.kit_fillings.create(@kit_filling)
                    loc = Kitting::Location.where('name LIKE ?', "Picking Queue")
                    Kitting::KitCopy.find_by_id(params[:kit_copy_id]).update_attribute("location_id",loc.first.id)
                    @kit_filling = Kitting::KitFilling.find(@kit_filling.id)
                    if kit_type == "multi-media-type"
                      all_cup_parts = Kitting::CupPart.where(:cup_id => Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id)).map(&:id)).where(:commit_status => true, :status=> 1)
                    else
                      all_cup_parts = @kit_filling.kit_copy.try(:kit).try(:cup_parts).where(:commit_status => true,status: 1)
                    end
                    all_cup_parts.map do |cup_part|
                      if cup_part.in_contract
                        filled_qty = (cup_part.demand_quantity == "Water-Level"  || cup_part.demand_quantity == "WL") ? "E" : 0
                        @kit_filling_details = { kit_filling_id: @kit_filling.id, cup_part_id: cup_part.id,filled_quantity: filled_qty, filled_state: 'E'}
                        @kit_filling_details = Kitting::KitFillingDetail.create(@kit_filling_details)
                        @filling_histories_details = {:kit_number=> @kit_filling.try(:kit_copy).try(:kit).try(:kit_number),:kit_copy_number=>@kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>@kit_filling.try(:customer).try(:cust_no),:cup_no=>cup_part.try(:cup).try(:cup_number),:part_number=>cup_part.try(:part).try(:part_number),:demand_qty=>cup_part.demand_quantity,:filled_qty=>filled_qty,:filling_date=>@kit_filling.created_at,:created_by=>@kit_filling.try(:customer).try(:user_name),:kit_filling_id=>@kit_filling.id,:cup_part_id=>cup_part.id,:cup_part_status=>cup_part.status,:cup_part_commit_status=>cup_part.commit_status}
                        @kit_filling_histories_report = Kitting::KitFillingHistoryReport.create(@filling_histories_details)
                      end
                    end
                  end
                  #################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
                  @kit= Kitting::KitFilling.find_by_id(@kit_filling.id).kit_copy.kit
                  check_approved_kit_and_update_accordingly(@kit,@kit_filling.id)
                  #################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
                  ##################### KIT FILLING FUNCTION STOP ###############################
                end
                @array_for_pick_ticket_details = []
                if params[:select_ids].present?
                  if @media_type.eql?("multi-media-type")
                    if params[:commit] == "Print Current Box"
                      session.delete(:pick_selected_cups)
                    else
                      params[:select_ids] = session[:pick_selected_cups] || []
                      session.delete(:pick_selected_cups)
                    end
                  end
                  params[:select_ids].each_with_index do |value, index|
                    compartment_details = @pick_ticket_print_details["kcpncompartmentNo"].collect { |print_data| print_data.split("-").last.strip }
                    if @media_type.eql?("multi-media-type")
                      orig_value = compartment_details.map.with_index {|a, i| a == value.split("-").first.strip ? i : nil}.compact
                      compartment_no = value.split("-").first.strip
                    else
                      compartment_details.map!(&:to_i).map!(&:to_s) if compartment_details.present?
                      orig_value = compartment_details.map.with_index {|a, i| a == value.split("-").first.strip ? i : nil}.compact
                      compartment_no = value.split("-").first.to_i
                      value = (value.split("-").first.to_i - 1)
                    end
                    orig_value.each do |index_data|
                      @hash_for_pick_ticket = {}
                      if @pick_ticket_print_details["kcpnbinLocation"][index_data].nil?
                        @pick_ticket_print_details["kcpnbinLocation"][index_data] = ""
                      end
                      @hash_for_pick_ticket = Hash["kcpncompartmentNo",@pick_ticket_print_details["kcpncompartmentNo"][index_data],"kcpnbinLocation",@pick_ticket_print_details["kcpnbinLocation"][index_data],"kitCompPartNo",@pick_ticket_print_details["kitCompPartNo"][index_data],"kcpnqty",@pick_ticket_print_details["kcpnqty"][index_data],"part_number",@pick_ticket_print_details["kcpnaltPN"][index_data],"tray_number",compartment_no]
                      @array_for_pick_ticket_details << @hash_for_pick_ticket
                    end
                    if params[:reprint].blank?
                      @kit_filling_data = Kitting::KitFilling.find(@kit_filling.id).try(:kit_copy).try(:kit).try(:cups).where('commit_status = ? and id = ?',true, params[:select_ids][index].split("-").last).map! do |cup|
                        cup.try(:cup_parts).where('commit_status = ? and status = ? ',true, 1).map! do |cup_part|
                          @kit_filling_details =  KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                          if cup_part.in_contract?
                            demand_quantity = find_cup_part_demand_qty(cup_part)
                            filled_quantity = cup_part.try(:demand_quantity)
                            @filled_state = find_filled_state(demand_quantity, filled_quantity)
                            @current_filled_quantity = @kit_filling_details.filled_quantity
                            @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status
                            @kit_filling_details.turn_count = 1
                            @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
                            @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                            @kit_filling_histories_report.update_attribute(:filled_qty, cup_part.try(:demand_quantity)) if cup_part.status
                          end
                        end
                      end
                      #------------------------------------------------------------------------
                    end
                  end
                else
                  # PICK TICKET PRINT FUNCTION
                  @pick_ticket_print_details["kcpncompartmentNo"].each_with_index do |value, index|
                    @hash_for_pick_ticket = {}
                    if @pick_ticket_print_details["kcpnbinLocation"][index].nil?
                      @pick_ticket_print_details["kcpnbinLocation"][index] = ""
                    end
                    @hash_for_pick_ticket = Hash["kcpncompartmentNo",value,"kcpnbinLocation",@pick_ticket_print_details["kcpnbinLocation"][index],"kitCompPartNo",@pick_ticket_print_details["kitCompPartNo"][index],"kcpnqty",@pick_ticket_print_details["kcpnqty"][index],"part_number",@pick_ticket_print_details["kcpnaltPN"][index],"tray_number",value.split("-").last]
                    @array_for_pick_ticket_details << @hash_for_pick_ticket
                  end
                  if params[:reprint].blank?
                    #------------------------------------------------------------------------
                    if kit_type == "multi-media-type"
                      all_cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id))
                    else
                      all_cups = Kitting::KitFilling.find(@kit_filling.id).try(:kit_copy).try(:kit).try(:cups)
                    end
                    @kit_filling_data = all_cups.where(:commit_status => true).map! do |cup|
                      cup.try(:cup_parts).where('commit_status = ? and status = ? ',true, 1).map! do |cup_part|
                        if cup_part.in_contract?
                          @kit_filling_details =  KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                          demand_quantity = find_cup_part_demand_qty(cup_part)
                          filled_quantity = cup_part.try(:demand_quantity)
                          @filled_state = find_filled_state(demand_quantity, filled_quantity)
                          @current_filled_quantity = @kit_filling_details.filled_quantity
                          @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status

                          @kit_filling_details.turn_count = 1
                          @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
                          @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                          @kit_filling_histories_report.update_attribute(:filled_qty, cup_part.try(:demand_quantity))
                        end
                      end
                    end
                    #Checking and updating filled state in fillings on quantity update
                    kit_fill_state = find_kit_current_filled_state(@kit_filling)
                    @kit_filling.update_attributes(:filled_state => kit_fill_state)
                    #------------------------------------------------------------------------
                  end
                end
                if params[:sort_by] == "Part Number"
                  @array_for_pick_ticket_details = @array_for_pick_ticket_details.sort_by { |hsh| hsh["kitCompPartNo"] }
                elsif params[:sort_by] == "Cup Number"
                  if kit_type == "multi-media-type"
                    cup_number_array = @array_for_pick_ticket_details.map{|x| x["tray_number"]}
                    cup_number_sort = cup_number_array.division_sort
                    @array_for_pick_ticket_details = @array_for_pick_ticket_details.sort_by{|x| cup_number_sort.index x["tray_number"]}
#                    @array_for_pick_ticket_details = @array_for_pick_ticket_details.sort_by { |hsh| hsh["tray_number"] }
                  else
                    @array_for_pick_ticket_details = @array_for_pick_ticket_details.sort_by { |hsh| hsh["tray_number"].to_i }
                  end
                else
                  @array_for_pick_ticket_details = @array_for_pick_ticket_details.sort_by { |hsh| hsh["kcpnbinLocation"] }
                end
                @kit_demand_details = invoke_webservice method: 'get', action: 'kitOpenOrder', query_string: { custNo:  current_user, kitId: params[:kit_number].upcase }
                if @kit_demand_details["orderNoList"].blank?
                  @order_no_list = ""
                else
                  @order_no_list = @kit_demand_details["orderNoList"].join(",")
                end
                if params[:reprint].blank?
                  unless @check_filling
                    @array_for_pick_ticket_details.each_with_index do |pick_ticket_value,index|
                      box_number = @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").first.to_i : ""
                      part_description = Kitting::Part.where(:part_number => pick_ticket_value["kitCompPartNo"]).first.name unless Kitting::Part.where(:part_number => pick_ticket_value["kitCompPartNo"]).blank?
                      @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)",kit_number,box_number, @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"], pick_ticket_value["kitCompPartNo"], Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                      if @turn_count_record.blank?
                        Kitting::TurnReportDetail.create(:kit_number => kit_number,:sub_kit_number => box_number, :kit_description => description, :cup_no => @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"],:part_number => pick_ticket_value["kitCompPartNo"], :"turns_copy#{version_number}".to_sym => 1, :part_description => part_description, :kit_media_type => kit_media_type, :cust_no => session[:customer_number])
                      else
                        temp = "turns_copy" + version_number
                        @turn_count = @turn_count_record.send(temp)
                        @turn_count_record.update_attribute(temp, @turn_count+1)
                      end
                    end
                  end
                  @check_filling = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:kit_copy_id],1)
                  if @check_filling
                    @array_for_pick_ticket_details.each_with_index do |pick_ticket_value,index|
                      box_number = @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").first.to_i : ""
                      @pick_ticket_history_count = Kitting::PickHistory.where("kit_number = ? AND box_number = ? AND cup_id = ? AND part_number = ? AND kit_filling_id = ? AND flag = ?",kit_number,box_number, @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"], pick_ticket_value["kitCompPartNo"],@check_filling.id, true).first
                      if @pick_ticket_history_count.blank?
                        Kitting::PickHistory.create(:kit_number => params[:kit_number].upcase,:bincenter => params[:bincenter],:kit_copy_id =>  @kit_copies.id,:created_by => current_user,:part_number => pick_ticket_value["kitCompPartNo"], :cup_id => @media_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"],:binlocation => pick_ticket_value["kcpnbinLocation"],:ordernolist => @order_no_list,:kit_filling_id => @check_filling.id, :flag => 1, :box_number => box_number )
                      end
                    end
                  end
                end
                @note = "&nbsp;"
                unless @kit_demand_details["orderNoList"].first.blank?
                  if @kit_demand_details["orderNoList"].length > 1
                    @note = "<span style=color:red;font-size:26px;>Note: There are open orders for kit " +params[:kit_number]+", with order numbers "+@kit_demand_details["orderNoList"].join(",")+". </span>"
                  else
                    @note = "<span style=color:red;font-size:26px;>Note: There is open order for kit " +params[:kit_number]+", with order number "+@kit_demand_details["orderNoList"].join(",")+". </span>"
                  end
                end
                kit_version = @kit_copies.kit.current_version if @kit_copies.kit.present?
                tracked_version = TrackCopyVersion.find_by_kit_copy_id(params[:kit_copy_id]).picked_version if TrackCopyVersion.find_by_kit_copy_id(params[:kit_copy_id]).present?
                if kit_version.present? and tracked_version.present?
                  if kit_version.to_i != tracked_version.to_i
                    @alert = "The Kit BOM has been modified from previous fill."
                    TrackCopyVersion.find_by_kit_copy_id(params[:kit_copy_id]).update_attribute("picked_version",kit_version)
                  end
                end
                respond_to do |format|
                  format.html do
                    render :pdf => "pick_ticket_print.html.erb",
                           :header => { :right => '[page] of [topage]',
                                        :line => true},
                           :footer => { :content => "#{@note}".html_safe,
                                        :line => true},
                           :margin => {:top =>9, :bottom => 22, :left => 12, :right => 12 }
                  end
                end
              end
            else
              render :text => "<script type=\"text/javascript\">if (confirm('Service temporary unavailable')){ window.close(); } </script>"
            end
          end
        else
          notice = "You may have clicked the refresh button after generating the pick ticket so you have been redirected, to reprint the pick ticket please search with the same copy number and reprint the Pick Ticket"
          respond_to do |format|
            format.html { redirect_to kit_copies_path, alert: notice }
            format.json { head :no_content }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is the show page for a kit copy.
##
    def show
      if can?(:>=, "4")
        @kit_copy = Kitting::KitCopy.find(params[:id])
        @copy_status = @kit_copy.status
        if @copy_status == 6
          @updated_by = @kit_copy.kit_status_details.last.updated_by
          @updated_at = @kit_copy.kit_status_details.last.updated_at
        end
        if @kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort
          mmt_kit_ids = @multi_media_kits.map {|m| m.id}
          kit_copy_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
          @kit = Kitting::Kit.find(kit_copy_id)
        else
          @kit = @kit_copy.kit
        end

      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action printing external and internal labels of a kit copy containing details at kit level as well as
# individual cup level.
##
    def print_label
      if can?(:>=, "4")
        if request.method == "POST"
          if params[:commit] == 'Print Internal Label' && params[:internal_label_type] == "label_4"
            if params[:kit_type] == 'multi-media-type'
              @kit_copy = Kitting::KitCopy.find(params[:id])
              parent_kit_id = Kitting::Kit.where(:id => params[:kit_id])
              child_kit_ids = Kitting::Kit.where(:parent_kit_id => params[:kit_id], :commit_status => true).sort
              mmt_kit_ids = child_kit_ids.map {|m| m.id}
              current_kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : child_kit_ids.first
              @cups = Kitting::Cup.where(:kit_id => current_kit_id)
              @current_kit_type = Kitting::Kit.where(:id => current_kit_id).first.kit_media_type.kit_type
            else
              @kit_copy = Kitting::KitCopy.find(params[:id])
              @cups = Kitting::KitCopy.find(params[:id]).kit.cups
            end
            respond_to do |format|
              format.html do
                render :pdf => "print_label.html.erb",
                       :page_height => '2in',
                       :page_width => '1.2in',
                       :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
                #:@kit_copy => {:font_name => "Lucida Sans Unicode", :l1_font_size => 25,:text => 'center'}
              end
            end
          elsif params[:commit] == 'Print Internal Label'
            if params[:kit_type] == 'multi-media-type'
              @kit_copy = Kitting::KitCopy.find(params[:id])
              parent_kit_id = Kitting::Kit.where(:id => params[:kit_id])
              child_kit_ids = Kitting::Kit.where(:parent_kit_id => params[:kit_id], :commit_status => true).sort
              mmt_kit_ids = child_kit_ids.map {|m| m.id}
              current_kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
              @cups = Kitting::Cup.where(:kit_id => current_kit_id)
              @current_kit_type = Kitting::Kit.where(:id => current_kit_id).first.kit_media_type.kit_type
            else
              @kit_copy = Kitting::KitCopy.find(params[:id])
              @cups = Kitting::KitCopy.find(params[:id]).kit.cups
            end
            respond_to do |format|
              format.html do
                render :pdf => "print_label.html.erb",
                       :page_height => '1.2in',
                       :page_width => '2in',
                       :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
                #:@kit_copy => {:font_name => "Lucida Sans Unicode", :l1_font_size => 25,:text => 'center'}
              end
            end
          elsif params[:commit] == 'Print All Internal Label'  && params[:all_internal_label_type] == "label_4"
            parent_kit_id = Kitting::Kit.where(:id => params[:kit_id])
            if parent_kit_id.present?
              @child_kit_ids = Kitting::Kit.where(:parent_kit_id => parent_kit_id).order("id asc").map(&:id)
              @cups = Kitting::Cup.where(:kit_id => @child_kit_ids)
              respond_to do |format|
                format.html do
                  render :pdf => "print_label.html.erb",
                         :page_height => '2in',
                         :page_width => '1.2in',
                         :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
                end
              end
            end
          elsif params[:commit] == 'Print All Internal Label'
            parent_kit_id = Kitting::Kit.where(:id => params[:kit_id])
            if parent_kit_id.present?
              @child_kit_ids = Kitting::Kit.where(:parent_kit_id => parent_kit_id).order("id asc").map(&:id)
              @cups = Kitting::Cup.where(:kit_id => @child_kit_ids)
              respond_to do |format|
                format.html do
                  render :pdf => "print_label.html.erb",
                         :page_height => '1.2in',
                         :page_width => '2in',
                         :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
                end
              end
            end
          elsif params[:commit] == 'Print External Label'
            @kit_copy = Kitting::KitCopy.find(params[:id])
            @kit_number = @kit_copy.kit.kit_number
            @bincenter = @kit_copy.kit.bincenter
            @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort
            @mmt_size = @multi_media_kits.size
            @label_print_details = invoke_webservice method: 'get', action: 'custInvInfo',query_string: { custNo:  current_user, primePN: @kit_number, binCenter: @bincenter }
            #@label_print_details = invoke_webservice method: 'get', action: 'custInvInfo',query_string: { custNo:  '029540', primePN: 'MR-1322-325', binCenter: '1322' }
            if @label_print_details
              if @label_print_details["errMsg"].present?
                render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@label_print_details["errMsg"]}')){ window.close(); } </script>"
              else
                respond_to do |format|
                  format.html do
                    render :pdf => "print_label.html.erb",
                           :page_height => '2in',
                           :page_width => '3in',
                           :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
                  end
                end
              end
            else
              render :text => "<script type=\"text/javascript\">if (confirm('Service temporary unavailable')){ window.close(); } </script>"
            end
          elsif params[:commit] == 'Print All External Label'
            @kit_copy = Kitting::KitCopy.find(params[:id])
            @kit_number = @kit_copy.kit.kit_number
            @bincenter = @kit_copy.kit.bincenter
            @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort
            @mmt_size = @multi_media_kits.size
            @label_print_details = invoke_webservice method: 'get', action: 'custInvInfo',query_string: { custNo:  current_user, primePN: @kit_number, binCenter: @bincenter }
            if @label_print_details
              if @label_print_details["errMsg"].present?
                render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@label_print_details["errMsg"]}')){ window.close(); } </script>"
              else
                respond_to do |format|
                  format.html do
                    render :pdf => "print_label.html.erb",
                           :page_height => '2in',
                           :page_width => '3in',
                           :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
                  end
                end
              end
            else
              render :text => "<script type=\"text/javascript\">if (confirm('Service temporary unavailable')){ window.close(); } </script>"
            end
          else
            @kit_copy = Kitting::KitCopy.find(params[:id])
            @kit = @kit_copy.kit
            if @kit_copy.kit.kit_media_type.kit_type == "multi-media-type" && params[:commit] != "Print Kit Template"
              @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort
              @mmt_size = @multi_media_kits.size
              @merge_path = Array.new
              @multi_media_kits.each_with_index do |kit, i|
                @kit = kit
                @mmt_kit_index = i + 1
                save_path = Rails.public_path+"/pdfs/#{kit.kit_number+ '_' + i.to_s}.pdf"
                if kit.kit_media_type.name == "Small Removable Cup TB"
                  pdf = WickedPdf.new.pdf_from_string(
                      render_to_string("print_label.html.erb" , :layout => false),
                      :orientation => 'Landscape',
                      :margin => {:top => 0,:bottom => 0,:left => 25,:right => 0 })
                  File.open(save_path, 'wb') do |file|
                    file << pdf
                  end
                else
                  pdf = WickedPdf.new.pdf_from_string(
                      render_to_string("print_label.html.erb", :layout => false),
                      :header => { :right => '[page] of [topage]',
                                   :line => true},
                      :footer => { :line => true},
                      :orientation => 'Landscape',
                      :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 } )
                  File.open(save_path, 'wb') do |file|
                    file << pdf
                  end
                end
                @merge_path << save_path
              end
              str = "#{Pdftk.config[:exe_path]} #{@merge_path.join(" ")} output #{Rails.public_path+"/pdfs/#{@kit_copy.kit.kit_number}.pdf"} dont_ask"
              Open3.popen3(str)
              sleep 1
              respond_to do |format|
                format.html do
                  send_file(File.open(Rails.public_path+"/pdfs/#{@kit_copy.kit.kit_number}.pdf"),:filename=> "MMT KIT",:disposition => "inline",:type => "application/pdf")
                end
              end
            else
              @mmt_kit = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort if @kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
              @kit= @mmt_kit[params[:box_number].to_i-1] if @kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
              if @kit.kit_media_type.name == "Small Removable Cup TB"
                respond_to do |format|
                  format.html do
                    render :pdf => "print_label.html.erb",
                           :orientation => 'Landscape',
                           :margin => {:top => 0,:bottom => 0,:left => 25,:right => 0 }
                  end
                end
              else
                respond_to do |format|
                  format.html do
                    render :pdf => "print_label.html.erb",
                           :header => { :right => '[page] of [topage]',
                                        :line => true},
                           :footer => { :line => true},
                           :orientation => 'Landscape',
                           :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
                  end
                end
              end
            end
          end

        else
          notice = "You may have clicked the refresh button after generating the label so you have been redirected, To reprint the label please search with the same kit copy number and print the label again."
          respond_to do |format|
            format.html { redirect_to kit_copies_path, alert: notice }
            format.json { head :no_content }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

##
# This action is called by an Ajax function used for acknowledging user on GUI that the KIT BOM has been modified
# when he/she is actually filling or printing a pick sheet.
##
    def change_data
      if request.xhr?
        @kit_copy = KitCopy.where('id= ?', params[:id])
        @kit = @kit_copy.first.kit
        @kit_bom_version = @kit.current_version
        @kit_copy_version = @kit_copy.first.version_status
        @change_data = invoke_webservice method: "get", action: "kitDelta", query_string: {kitBomVersion: @kit_bom_version, kitNo: @kit.kit_number, kitCopyVersion: @kit_copy_version }
      end
    end

##
# This action for printing the changed BOM information in pdf.
##
    def print_change_data
      @change_data = JSON.parse(params[:change_data])
      if params[:commit] == 'Print'
        respond_to do |format|
          format.html do
            render :pdf => "print_change_data.html.erb",
                   :header => { :right => '[page] of [topage]',
                                :line => true},
                   :footer => { :line => true},
                   :margin => {:top =>9, :bottom => 22, :left => 12, :right => 12 }
          end
        end
      elsif params[:commit] == 'Print Internal Label'
        respond_to do |format|
          format.html do
            render :pdf => "print_change_data.html.erb",
                   :page_height => '1.2in',
                   :page_width => '2.1in',
                   :margin => {:top => 0.5,:bottom => 0,:left => 0,:right => 0 }
          end
        end
      end
    end

    def kit_receiving
      redirect_to main_app.unauthorized_url unless session[:user_level] > "3"
    end

##
# This action is for deleting  kit copies which are in NEW KIT QUEUE location. It is listed under administration
# panel.
##
    def delete_copy
      if can?(:>=, "5")
        unless params[:delete_notice].blank?
          flash[:notice] = "Copy Deleted Successfully"
        end
        unless params[:prevent_delete].blank?
          flash[:notice] = "This Copy is either under filling or has been shipped, hence cannot be deleted."
        end

        new_kit_loc = Location.where(:name => "NEW KIT QUEUE").first.id
        if params[:kit_copy_number].present?
          if params[:page].nil?
            params[:page] = 1
          end
          search = params[:kit_copy_number].try(:upcase).try(:strip)
          if search[-1] == "X" or search[-1] == "Y" or search[-1] == "Z"
            code = rate params[:kit_copy_number].try(:strip)[-1]
            search = search.chop + code.to_s
          end
          @kit_copy = Kitting::KitCopy.where("kit_version_number = ? and customer_id IN (?) and status = ?", search,current_company,1)
          if @kit_copy.count == 1
            copy_loc = @kit_copy.first.location.name
            if copy_loc != "NEW KIT QUEUE"
              flash[:notice] = "Cant"
              respond_to do |format|
                format.html { redirect_to kit_copy_delete_path(:prevent_delete => "Cant delete") }
              end
            end
          end
          @kit_copies = Kitting::KitCopy.where("kit_version_number LIKE ? and customer_id IN (?) and location_id = ? and status = ?","%#{search}%",current_company,new_kit_loc, 1).paginate(:page => params[:page],:per_page => 100).order('created_at desc')
        end
      end
    end

##
# This action is called when cancel button is clicked while filling a kit copy, it destroys a Kit Copy and all its
# associations.
##
    def destroy
      if can?(:>=, "5")
        @kit_copy = Kitting::KitCopy.find(params[:id])
        @kit_copy.destroy

        respond_to do |format|
          format.html { redirect_to kit_copy_delete_path(:delete_notice => "Copy Deleted Successfully") }
        end
      end
    end

##
# This action is for updating a kit copies' location(queue). Only those copies which are not in the restricted_locations
# can be moved.
##
    def update_queue
      restricted_locations = ['Send to Stock', 'SOS Queue', 'NEW KIT QUEUE', 'Ship/Invoice', 'Picking Queue']
      @locations = Kitting::Location.where('customer_number = ? AND name not in (?)',session[:customer_number], restricted_locations)
      updated_copies = Array.new
      unupdated_copies = Array.new
      count = 0
      if params[:scan_copy_numbers].present? && params[:location].present?
        copies_array = params[:scan_copy_numbers].split(/,|\r\n/)
        copies_array.each do |copy_number|
          unless copy_number.blank?
            copy_number.upcase!
            search_copy = copy_number.strip
            if search_copy[-1] == "X" or search_copy[-1] == "Y" or search_copy[-1] == "Z"
              code = rate copy_number.try(:strip)[-1]
              search_copy = search_copy.chop + code.to_s
            end
            update_copy_queue = Kitting::KitCopy.where('kit_version_number =? and customer_id in (?) and status =?', search_copy, current_company,1).try(:first)
            location = Kitting::Location.where(:name => params[:location]).try(:first).try(:id)
            if update_copy_queue.present?
              flag = update_copy_queue.update_attribute('location_id', location)
              if flag
                updated_copies << copy_number
              end
            else
              unupdated_copies << copy_number
            end
          end
        end
      end
      if params[:scan_copy_numbers].present? && params[:location].present?
        if unupdated_copies.blank?
          flash[:notice] ="<div class='alert alert-success'><p><strong>Successfully Moved Following Kits to #{params[:location]}</strong></p>#{updated_copies.join("</br>")}</div>".html_safe
        elsif updated_copies.blank?
          flash[:notice] ="<div class='alert alert-danger'><p><strong> The following Kit Copy Numbers are Invalid hence cannot move them.</strong></p>#{unupdated_copies.join("</br>")}</div>".html_safe
        else
          flash[:notice] =" <div class='alert alert-success'><p><strong>Successfully Moved Following Kits to #{params[:location]}</strong></p>#{updated_copies.join("</br>")}</div>
                            <div class='alert alert-danger'><p><strong>The following Kit Copy Numbers are Invalid hence cannot move them.</strong></p>#{unupdated_copies.join("</br>")}</div>".html_safe
        end
        redirect_to kit_queue_update_path
      end
    end

    def manage_rfid
      if can?(:>=, "4")
        @kit_copy = Kitting::KitCopy.find(params[:kit_copy_id])
        if @kit_copy.blank?
          flash[:notice] ="<div class='alert alert-danger'><p><strong>No kit copy is found.</strong></p></div>".html_safe
        else
          begin
            @kit_copy.update_attribute('rfid_number', params[:rfid_serial_number])
            flash[:notice] ="<div class='alert alert-success'><p><strong>RFID Serial Number is successfully updated..</strong></p></div>".html_safe
          rescue ActiveRecord::RecordNotUnique
            flash[:notice] ="<div class='alert alert-danger'><p><strong>RFID Serial Number already exists. Please enter a unique value.</strong></p></div>".html_safe
          end
        end
        redirect_to :back
      else
        redirect_to main_app.unauthorized_url
      end
    end

    private
##
#  This private method takes in X,Y or Z as argument and convert X->1 Y->2 Z->3 it is used when kit copy number is
#  scanned by X Y or Z in place of numbers
##
    def rate code
      case code
        when "X"
          return 1
        when "Y"
          return 2
        when "Z"
          return 3
        else
          return ""
      end
    end

    def clean_pdf
      @merge_path.map{|file| FileUtils.rm(file)} rescue "EMPTY FILES"
    end

  end
end