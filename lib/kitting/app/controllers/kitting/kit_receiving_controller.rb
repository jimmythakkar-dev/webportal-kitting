require_dependency "kitting/application_controller"

module Kitting
  class KitReceivingController < ApplicationController

    layout "kitting/fit_to_compartment", :only => [ :create_filling_show, :edit, :kit_filling_edit ]
    before_filter :get_acess_right

    protect_from_forgery
    include KitsHelper
    include Kitting::KitCopiesHelper
    include Kitting::KitFillingHelper

    ##
    # This action is of index page of the Received Kits listing as per user access
    ##
    def index
      if can?(:>=, "4")
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action lists all the kits received based on the search criteria entered by the user
    ##
    def search
      params["kit_copy_number_search"].upcase!
      @search_copy = params["kit_copy_number_search"].try(:strip)
      if @search_copy[-1] == "X" or @search_copy[-1] == "Y" or @search_copy[-1] == "Z"
        @code = rate params["kit_copy_number_search"].try(:strip)[-1]
        @search_copy = @search_copy.chop + @code.to_s
      end
      if Kitting::KitCopy.where("kit_version_number LIKE ?","%"+ @search_copy +"%").present?
        sql = "select * from kit_copies where id IN(select kit_copy_id from kit_fillings where flag = 0 GROUP by kit_copy_id) and kit_version_number LIKE '%#{@search_copy}%' and customer_id IN (#{current_company.join(',')}) and status != 6"
        @kit_copy_response = Kitting::KitCopy.paginate_by_sql(sql,:page =>params[:page].nil? ? 1 : params[:page], :per_page => 100)
        render 'search_result'
      else
        flash.now[:message] = "Please enter a valid part of kit copy number"
        render 'index'
      end
    end

    ##
    # This action initializes the receiving process and creates entry in the filling and filling details table
    # of the received kit.
    ##
    def create_filling_show
      if can?(:>=, "4")
        @check_filling = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:id],1)
        unless @check_filling && params[:kit_filling_id].blank?
          loc = Kitting::Location.where('name LIKE ?', "Picking Queue")
          Kitting::KitCopy.find_by_id(params[:id]).update_attribute("location_id",loc.first.id)
          @kit_filling = {kit_copy_id: params[:id],created_by: current_user, received: params[:received], flag: 1}
          @kit_filling = current_customer.kit_fillings.create(@kit_filling)
          @kit_filling = Kitting::KitFilling.find(@kit_filling.id)
          kit_type = @kit_filling.kit_copy.kit.kit_media_type.kit_type
          if kit_type == "multi-media-type"
            all_cup_parts = Kitting::CupPart.where(:cup_id => Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id)).map(&:id)).where(:commit_status => true, :status=> 1)
          else
            all_cup_parts = @kit_filling.kit_copy.try(:kit).try(:cup_parts).where(:commit_status => true,status: 1)
          end
          all_cup_parts.map do |cup_part|
            if cup_part.in_contract?
              filled_qty = (cup_part.demand_quantity == "Water-Level"  || cup_part.demand_quantity == "WL") ? "E" : 0
              @kit_filling_details = { kit_filling_id: @kit_filling.id, cup_part_id: cup_part.id,filled_quantity: filled_qty, filled_state: 'E' }
              @kit_filling_details = Kitting::KitFillingDetail.create(@kit_filling_details)
              @filling_histories_details = {:kit_number=> @kit_filling.try(:kit_copy).try(:kit).try(:kit_number),:kit_copy_number=>@kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>@kit_filling.try(:customer).try(:cust_no),:cup_no=>cup_part.try(:cup).try(:cup_number),:part_number=>cup_part.try(:part).try(:part_number),:demand_qty=>cup_part.demand_quantity,:filled_qty=>cup_part.demand_quantity,:filling_date=>@kit_filling.created_at,:created_by=>@kit_filling.try(:customer).try(:user_name),:kit_filling_id=>@kit_filling.id,:cup_part_id=>cup_part.id,:cup_part_status=>cup_part.status,:cup_part_commit_status=>cup_part.commit_status}
              @kit_filling_histories_report = Kitting::KitFillingHistoryReport.create(@filling_histories_details)
            end
          end
        else
          @kit_filling = @check_filling
        end
        kit_type = @kit_filling.kit_copy.kit.kit_media_type.kit_type
        if kit_type == "multi-media-type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_copy.kit.id,true).sort
          mmt_kit_ids = @multi_media_kits.map {|m| m.id}
          kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
          @kit = Kitting::Kit.find(kit_id)
        else
          @kit = @kit_filling.kit_copy.kit
        end
        @kit_copy = Kitting::KitCopy.find_by_id(params[:id])
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = []
        @binCenters_response['binCenterList'].each do |i|
          @binCenters << i
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Edit a Received Kit called for binder type of kit
    ##
    def edit
      if can?(:>=, "4")
        @kit_filling = Kitting::KitFilling.find(params[:id])
        @kit_copy = Kitting::KitFilling.find(params["id"]).kit_copy
        @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
        @binCenters = []
        @binCenters_response['binCenterList'].each do |i|
          @binCenters << i
        end
        @kit_type =  @kit_copy.kit.kit_media_type.kit_type
        if @kit_type == "multi-media-type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id(@kit_copy.kit.id).sort
          @mmt_kit_copies = Kitting::Kit.where(:parent_kit_id => @kit_copy.kit.id, :commit_status => true,:commit_id => nil).order("id ASC") if @kit_copy.kit.present?
          mmt_kit_ids = @multi_media_kits.map {|m| m.id}
          kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first

          @kit = Kitting::Kit.find(kit_id)
        else
          @kit = @kit_copy.kit
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Edit a Received Kit
    ##
    def kit_filling_edit
      if can?(:>=, "4")
        if request.method == "POST"
          @kit_filling = Kitting::KitFilling.find(params["kit_filling_id"])
          @kit_copy = @kit_filling.kit_copy
          kit_filling_update = Kitting::KitFilling.find(params["kit_filling_id"])
          @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
          @binCenters = []
          @binCenters_response['binCenterList'].each do |i|
            @binCenters << i
          end
          @kit_type =  @kit_copy.kit.kit_media_type.kit_type
          if @kit_type == "multi-media-type"
            @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copy.kit.id,true).sort
            mmt_kit_ids = @multi_media_kits.map {|m| m.id}
            kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
            @kit = Kitting::Kit.find(kit_id)
          else
            @kit = @kit_copy.kit
          end
          if params[:member_data].present?
            ################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
            kit_to_check= kit_filling_update.kit_copy.kit
            check_approved_kit_and_update_accordingly(kit_to_check,params[:member_data][:kit_filling_id])
            ################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################

            @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?', params[:member_data][:kit_filling_id],params[:member_data][:cup_part_id] ).first

            filled_qty = convert_index_to_qty_for_wl(params[:filled_quantity][:qty])
            demand_quantity = find_cup_part_demand_qty(params[:member_data][:cup_part_id])
            filled_quantity = filled_qty
            @filled_state = find_filled_state(demand_quantity, filled_quantity)

            @kit_filling_details.update_attributes(filled_quantity: filled_qty, filled_state: @filled_state)
            #Checking and updating filled state in fillings on quantity update
            kit_fill_state = find_kit_current_filled_state(kit_filling_update)
            kit_filling_update.update_attributes(:filled_state => kit_fill_state)
            @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:member_data][:kit_filling_id],params[:member_data][:cup_part_id]).first
            if @kit_filling_histories_report.present?
              if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "S"
                required_qty = "S"
              elsif @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "E"
                required_qty = "WL"
              else
                required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
              end
              @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
            end
            # @kit_copy = Kitting::KitCopy.find_by_id(params[:id])
            respond_to do |format|
              format.js {}
            end
          else
            ################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
            kit_to_check= kit_filling_update.kit_copy.kit
            check_approved_kit_and_update_accordingly(kit_to_check,params[:kit_filling_id])
            ################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
            params[:cup_part_id].each_with_index do |id,index|
              @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?', params[:kit_filling_id],id ).first

              demand_quantity = find_cup_part_demand_qty(id)
              filled_quantity = params[:filled_quantity][index]
              @filled_state = find_filled_state(demand_quantity, filled_quantity)

              @kit_filling_details.update_attributes(filled_quantity: params[:filled_quantity][index], filled_state: @filled_state)
              #Checking and updating filled state in fillings on quantity update
              kit_fill_state = find_kit_current_filled_state(kit_filling_update)
              kit_filling_update.update_attributes(:filled_state => kit_fill_state)
              @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:kit_filling_id],id).first
              if @kit_filling_histories_report.present?
                if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "S"
                  required_qty = "S"
                elsif @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "E"
                  required_qty = "WL"
                else
                  required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
                end
                @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
              end
              #@kit_copy = Kitting::KitCopy.find_by_id(params[:id])
            end
            # respond_to do |format|
            #   format.html  { redirect_to(d_kit_filling_path(params[:kit_filling_id]),:notice => "Cup filling updated Successfully.") }
            #   format.json  { head :no_content }
            # end
          end
        else
          if params[:mmt_kit_id] && params[:kit_filling_id]
            redirect_to edit_kit_receiving_path(:id => params[:kit_filling_id], :mmt_kit_id => params[:mmt_kit_id])
          elsif params[:mmt_kit_id] && params[:kit_filling_id].blank?
            redirect_to edit_kit_receiving_path(:id => params[:id], :mmt_kit_id => params[:mmt_kit_id])
          else
            redirect_to create_filling_show_kit_receiving_path
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # Print the pick sheet of the toggled or all cup parts.
    ##
    def pick_ticket_print
      if can?(:>=, "4")
        if request.method == "POST"
          @kit_copies = Kitting::KitCopy.find(params[:kit_id])
          kit_version_number = @kit_copies.kit_version_number
          version_number = kit_version_number.split("-").last
          kit_number = @kit_copies.kit.kit_number
          description = @kit_copies.kit.description
          kit_type = @kit_copies.kit.kit_media_type.kit_type
          select_cup_numbers = []
          if kit_type.eql?("multi-media-type")
            if params[:commit].eql?("Print Pick Sheet") || params[:commit].eql?("Print Pick Ticket")
              multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_copies.kit.id,true).sort
              check_filling_details = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:kit_id],1)
              if check_filling_details
                all_cup_parts = Kitting::CupPart.where(:cup_id => Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => check_filling_details.kit_copy.kit.id).where(:commit_status => true).map(&:id)).map(&:id)).where(:commit_status => true, :status=> 1)
                all_cup_parts.map do |cup_part|
                  if cup_part.in_contract
                    box_no = box_no || multi_media_kits.index(multi_media_kits.select { |kit| kit.id == cup_part.cup.kit_id}.first) + 1
                    kit_filling_details = Kitting::KitFillingDetail.where(kit_filling_id: check_filling_details.id, cup_part_id: cup_part.id)
                    if kit_filling_details.present?
                      if kit_filling_details.first.present?
                        if kit_filling_details.first.filled_state == "E" || kit_filling_details.first.filled_state == "P"
                          select_cup_numbers << "#{box_no}/#{kit_filling_details.first.cup_part.cup.cup_number} - #{kit_filling_details.first.cup_part.cup_id}"
                        end
                      end
                    end
                  end
                end
              end
              if params[:commit].eql?("Print Pick Sheet")
               params[:select_ids] = select_cup_numbers
              else
                params[:select_ids_for_alternate] = select_cup_numbers
              end
            end
          end
          if (params[:select_ids_for_alternate])
            params[:select_ids] = params[:select_ids_for_alternate].join(",").split(",")
          end
          if  params[:select_ids].present? && (params[:select_ids].include?(nil) || params[:select_ids].include?(""))
            render :text => "<script type=\"text/javascript\">if (confirm('One or more parts contains errors hence the pick sheet cannot be generated.')){ window.close(); } </script>"
          elsif kit_type.eql?("multi-media-type") && params[:commit].eql?("Print Pick Sheet") && params[:select_ids].blank?
            render :text => "<script type=\"text/javascript\">if (confirm('There is No Partial or Empty Compartments to Print Pick Sheet.')){ window.close(); } </script>"
          elsif kit_type.eql?("multi-media-type") && params[:commit].eql?("Print Pick Ticket") && params[:select_ids_for_alternate].blank?
            render :text => "<script type=\"text/javascript\">if (confirm('There is No Partial or Empty Compartments to Print Pick Sheet.')){ window.close(); } </script>"
          else
            @pick_ticket_print_details = invoke_webservice method: 'get', action: 'pickTicket',
                                                           query_string: { kitNo: params[:kit_number].upcase,
                                                                           custNo:  current_user,
                                                                           binCenter: params[:bincenter]
                                                           }
            if @pick_ticket_print_details
              if @pick_ticket_print_details["errMsg"].present?
                render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@pick_ticket_print_details["errMsg"]}')){ window.close(); } </script>"
              else
                #              KIT FILLING FUNCTION
                #------------------------------------------------------------------------

                @check_filling = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:kit_id],1)
                unless @check_filling
                  @kit_filling = {kit_copy_id: params[:kit_id],flag: 1,created_by: current_user }
                  @kit_filling = current_customer.kit_fillings.create(@kit_filling)
                  @kit_filling = Kitting::KitFilling.find(@kit_filling.id)
                  if kit_type.eql?("multi-media-type")
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

                else
                  @kit_filling = @check_filling
                end
                #################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
                @kit= Kitting::KitFilling.find_by_id(@kit_filling.id).kit_copy.kit
                check_approved_kit_and_update_accordingly(@kit,@kit_filling.id)
                #################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################

                #------------------------------------------------------------------------
                @array_for_pick_ticket_details = []
                filled_array = []
                if params[:select_ids].present?
                  params[:select_ids].each_with_index do |value, index|

                    #------------------------------------------------------------------------
                    # @kit_filling.kit_copy.try(:kit).try(:cup_parts).where('cup_parts.cup_id = ? and cup_parts.status = ?',params[:select_ids][index].split("-").last,1).map do |cup_part|
                    #   @kit_filling_details = { kit_filling_id: @kit_filling.id, cup_part_id: cup_part.id,filled_quantity: 0, filled_state: 'E'}
                    #   @kit_filling_details = Kitting::KitFillingDetail.create(@kit_filling_details)
                    # end
                    if kit_type.eql?("multi-media-type")
                      all_selected_cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id))
                    else
                      all_selected_cups = Kitting::KitFilling.find(@kit_filling.id).try(:kit_copy).try(:kit).try(:cups)
                    end

                    @kit_filling_data = all_selected_cups.where('commit_status = ? and id = ?',true, params[:select_ids][index].split("-").last).map! do |cup|
                      cup.try(:cup_parts).where('commit_status = ? and status = ? ',true, 1).map! do |cup_part|
                        if cup_part.in_contract?
                          @kit_filling_details =  KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                          demand_quantity = find_cup_part_demand_qty(cup_part)
                          filled_quantity = cup_part.try(:demand_quantity)
                          @filled_state = find_filled_state(demand_quantity, filled_quantity)
                          @current_filled_quantity = @kit_filling_details.filled_quantity
                          filled_array << @current_filled_quantity
                          #if @current_filled_quantity.to_i == 0 || @current_filled_quantity == "E"
                          #  @current_filled_quantity = cup_part.try(:demand_quantity)
                          #end
                          @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                          if @kit_filling_histories_report.present?
                            if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_histories_report.filled_qty == "S"
                              required_qty = "S"
                            elsif @kit_filling_histories_report.demand_qty == "WL" && (@kit_filling_histories_report.filled_qty == "E" || @kit_filling_histories_report.filled_qty == "WL")
                              required_qty = "WL"
                            else
                              required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
                            end
                            @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
                          end
                          @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status


                          @kit_filling_details.turn_count = 1
                          @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
                        end
                      end
                    end
                    #Checking and updating filled state in fillings on quantity update
                    kit_fill_state = find_kit_current_filled_state(@kit_filling)
                    @kit_filling.update_attributes(:filled_state => kit_fill_state)
                    #------------------------------------------------------------------------
                    compartment_details = @pick_ticket_print_details["kcpncompartmentNo"].collect { |print_data| print_data.split("-").last.strip }
                    if kit_type.eql?("multi-media-type")
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
                      @hash_for_pick_ticket = Hash["kcpncompartmentNo",@pick_ticket_print_details["kcpncompartmentNo"][index_data],"kcpnbinLocation",@pick_ticket_print_details["kcpnbinLocation"][index_data],"kitCompPartNo",@pick_ticket_print_details["kitCompPartNo"][index_data],"kcpnqty",@pick_ticket_print_details["kcpnqty"][index_data],"part_number",@pick_ticket_print_details["kcpnaltPN"][index_data],"tray_number",compartment_no,"fillqty",filled_array[index]]
                      @array_for_pick_ticket_details << @hash_for_pick_ticket
                    end
                  end
                else
                  #             PICK TICKET PRINT FUNCTION
                  #------------------------------------------------------------------------
                  # @kit_filling.kit_copy.try(:kit).try(:cup_parts).where(status: 1).map do |cup_part|
                  #   @kit_filling_details = { kit_filling_id: @kit_filling.id, cup_part_id: cup_part.id,filled_quantity: 0, filled_state: 'E'}
                  #   @kit_filling_details = Kitting::KitFillingDetail.create(@kit_filling_details)
                  # end

                  if kit_type.eql?("multi-media-type")
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
                        filled_array << @current_filled_quantity
                        #if @current_filled_quantity.to_i == 0 || @current_filled_quantity == "E"
                        #  @current_filled_quantity = cup_part.try(:demand_quantity)
                        #end

                        @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',@kit_filling.id,cup_part).first
                        if @kit_filling_histories_report.present?
                          if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_histories_report.filled_qty == "S"
                            required_qty = "S"
                          elsif @kit_filling_histories_report.demand_qty == "WL" && (@kit_filling_histories_report.filled_qty == "E" || @kit_filling_histories_report.filled_qty == "WL")
                            required_qty = "WL"
                          else
                            required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
                          end
                          @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
                        end
                        @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status
                        @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
                      end
                    end
                  end

                  #Checking and updating filled state in fillings on quantity update
                  kit_fill_state = find_kit_current_filled_state(@kit_filling)
                  @kit_filling.update_attributes(:filled_state => kit_fill_state)
                  @kit_filling_details.turn_count = 1
                  #------------------------------------------------------------------------

                  @pick_ticket_print_details["kcpncompartmentNo"].each_with_index do |value, index|
                    @hash_for_pick_ticket = {}
                    if @pick_ticket_print_details["kcpnbinLocation"][index].nil?
                      @pick_ticket_print_details["kcpnbinLocation"][index] = ""
                    end
                    @hash_for_pick_ticket = Hash["kcpncompartmentNo",value,"kcpnbinLocation",@pick_ticket_print_details["kcpnbinLocation"][index],"kitCompPartNo",@pick_ticket_print_details["kitCompPartNo"][index],"kcpnqty",@pick_ticket_print_details["kcpnqty"][index],"part_number",@pick_ticket_print_details["kcpnaltPN"][index],"tray_number",value.split("-").last,"fillqty",filled_array[index]]
                    @array_for_pick_ticket_details << @hash_for_pick_ticket
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
                @kit_demand_details = invoke_webservice method: 'get', action: 'kitOpenOrder',
                                                        query_string: { custNo:  current_user, kitId: params[:kit_number].upcase }
                if @kit_demand_details["errMsg"].blank?
                  if @kit_demand_details["orderNoList"].first.blank?
                    @order_no_list = ""
                  else
                    @order_no_list = @kit_demand_details["orderNoList"].join(",")
                  end
                else
                  @order_no_list = ""
                end
                @array_for_pick_ticket_details.each_with_index do |pick_ticket_value,index|
                  kit_media_type = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:kit_media_type).try(:name)
                  part_description = @kit_filling_details.try(:cup_part).try(:part).try(:name)
                  box_number = kit_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").first.to_i : ""
                  @pick_ticket_history_count = Kitting::PickHistory.where("kit_number = ? AND cup_id = ? AND box_number = ? AND part_number = ? AND kit_filling_id = ? AND flag = ?",kit_number,kit_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"],box_number, pick_ticket_value["kitCompPartNo"],@kit_filling.id, true).first
                  if @pick_ticket_history_count.blank?
                    if kit_type == "multi-media-type"
                       @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND cup_no = ? AND part_number = ? AND sub_kit_number = ? AND (created_at between ? and ?)",kit_number,pick_ticket_value["tray_number"].to_s.split("/").last.to_i, pick_ticket_value["kitCompPartNo"],pick_ticket_value["tray_number"].split("/").first, Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                      if @turn_count_record.blank?
                        Kitting::TurnReportDetail.create(:kit_number => kit_number, :kit_description => description, :cup_no => pick_ticket_value["tray_number"].to_s.split("/").last.to_i,:sub_kit_number => pick_ticket_value["tray_number"].split("/").first,:part_number => pick_ticket_value["kitCompPartNo"], :"turns_copy#{version_number}".to_sym => 1, :kit_media_type => kit_media_type, :part_description => part_description, :cust_no => session[:customer_number])
                      else
                        temp = "turns_copy" + version_number
                        @turn_count = @turn_count_record.send(temp)
                        @turn_count_record.update_attribute(temp, @turn_count+1)
                      end
                    else
                      @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)",kit_number,pick_ticket_value["tray_number"], pick_ticket_value["kitCompPartNo"], Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                      if @turn_count_record.blank?
                        Kitting::TurnReportDetail.create(:kit_number => kit_number, :kit_description => description, :cup_no => pick_ticket_value["tray_number"],:part_number => pick_ticket_value["kitCompPartNo"], :"turns_copy#{version_number}".to_sym => 1, :kit_media_type => kit_media_type, :part_description => part_description, :cust_no => session[:customer_number])
                      else
                        temp = "turns_copy" + version_number
                        @turn_count = @turn_count_record.send(temp)
                        @turn_count_record.update_attribute(temp, @turn_count+1)
                      end
                    end
                  end
                end
                @array_for_pick_ticket_details.each_with_index do |pick_ticket_value,index|
                  box_number = kit_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").first.to_i : ""
                  @pick_ticket_history_count = Kitting::PickHistory.where("kit_number = ? AND cup_id = ? AND box_number = ? AND part_number = ? AND kit_filling_id = ? AND flag = ?",kit_number,kit_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"],box_number, pick_ticket_value["kitCompPartNo"],@kit_filling.id, true).first
                  if @pick_ticket_history_count.blank?
                    Kitting::PickHistory.create(:kit_number => params[:kit_number].upcase,:bincenter => params[:bincenter],:kit_copy_id =>  @kit_copies.id,:created_by => current_user,:part_number => pick_ticket_value["kitCompPartNo"], :cup_id => kit_type.eql?("multi-media-type") ?  pick_ticket_value["tray_number"].to_s.split("/").last.to_i : pick_ticket_value["tray_number"],:binlocation => pick_ticket_value["kcpnbinLocation"],:ordernolist => @order_no_list,:kit_filling_id => @kit_filling.id, :flag => 1, :box_number => box_number )
                  end
                end

                @note = "&nbsp;"
                if @kit_demand_details["errMsg"].blank?
                  unless @kit_demand_details["orderNoList"].first.blank?
                    if @kit_demand_details["orderNoList"].length > 1
                      @note = "<span style=color:red;font-size:26px;>Note: There are open orders for kit " +params[:kit_number]+", with order numbers "+@kit_demand_details["orderNoList"].join(",")+". </span>"
                    else
                      @note = "<span style=color:red;font-size:26px;>Note: There is open order for kit " +params[:kit_number]+", with order number "+@kit_demand_details["orderNoList"].join(",")+". </span>"
                    end
                  end
                else
                  @note = "&nbsp;"
                end
                kit_version = @kit_copies.kit.current_version if @kit_copies.kit.present?
                tracked_version = TrackCopyVersion.find_by_kit_copy_id(params[:kit_id]).picked_version if TrackCopyVersion.find_by_kit_copy_id(params[:kit_id]).present?

                if kit_version.present? and tracked_version.present?
                  if kit_version.to_i != tracked_version.to_i
                    @alert = "The Kit BOM has been modified from previous fill."
                    TrackCopyVersion.find_by_kit_copy_id(params[:kit_id]).update_attribute("picked_version",kit_version)
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
          notice = "You may have clicked the refresh button after generating the pick ticket so you have been redirected."
          respond_to do |format|
            format.html { redirect_to kit_receiving_path, alert: notice }
            format.json { head :no_content }
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    ##
    # This action updates the quantity of all cup parts and makes it full equal to the demand quantity.
    ##
    def fill_all_cups
      #################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
      @kit= Kitting::KitFilling.find_by_id(params[:id]).kit_copy.kit
      check_approved_kit_and_update_accordingly(@kit,params[:id])
      #################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
      kit_filling_update = Kitting::KitFilling.find(params[:id])
      if @kit.kit_media_type.kit_type == "multi-media-type"
        cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit.id).where(:commit_status => true).map(&:id),:commit_status => true)
      else
        cups =  @kit.try(:cups).where(:commit_status => true)
      end
      cups.map! do |cup|
        cup.try(:cup_parts).where('commit_status = ? and status = ? ',true, 1).map! do |cup_part|
        if cup_part.in_contract
          @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?',params[:id],cup_part).first
          demand_quantity = find_cup_part_demand_qty(cup_part)
          filled_quantity = cup_part.try(:demand_quantity)
          @filled_state = find_filled_state(demand_quantity, filled_quantity)
          @current_filled_quantity = @kit_filling_details.filled_quantity
          @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status
          @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:id],cup_part).first
          if @kit_filling_histories_report.present?
            if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "S"
              required_qty = "S"
            elsif @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "E"
              required_qty = "WL"
            else
              required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
            end
            @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
          end
        end
        end
      end

      #Checking and updating filled state in fillings on quantity update
      kit_fill_state = find_kit_current_filled_state(kit_filling_update)
      kit_filling_update.update_attributes(:filled_state => kit_fill_state)

      respond_to do |format|
        format.html  { redirect_to(edit_kit_receiving_path(:id => params[:id]),:notice => "Cup filling updated Successfully.") }
        format.json  { head :no_content }
      end
    end

    ##
    # TODO remove this action if never used
    ##
    def destroy
      @kit_filling = Kitting::KitFilling.find(params[:id])
      @kit_filling.destroy

      respond_to do |format|
        format.html { redirect_to kit_copies_path, notice: 'Kit Filling Canceled successfully.'}
        format.json { head :no_content }
      end
    end

    ##
    # Toggles the Filled Quantity of parts whose demand quantity is WL. The toggle is in a cycle from
    # Empty -> Short -> Full
    ##
    def toggle_data
      if can?(:>=, "4")
        if request.xhr?
          @kit_copy = Kitting::KitFilling.find(params["kit_filling_id"]).kit_copy
          kit_filling_update = Kitting::KitFilling.find(params[:kit_filling_id])
          @binCenters_response = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
          @binCenters = []
          if @binCenters_response.present?
            if @binCenters_response['errMsg'].present?
              @binCenters << @binCenters_response['errMsg']
            else
              @binCenters_response['binCenterList'].each do |i|
                @binCenters << i
              end
            end
          else
            @binCenters << "Service Temporarily Unavailable"
          end
          ################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
          @kit= Kitting::Kit.find_by_kit_number_and_status(params[:kit_number],1)
          check_approved_kit_and_update_accordingly(@kit,params[:kit_filling_id])
          ################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
          params[:cup_part_id].each_with_index do |id,index|
            @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?', params[:kit_filling_id],id ).first
            demand_quantity = find_cup_part_demand_qty(id)
            filled_quantity = params[:filled_quantity][index]
            quantity_to_be_filled = toggle_val(filled_quantity)
            @filled_state = find_filled_state(demand_quantity, quantity_to_be_filled)
            status = @kit_filling_details.update_attributes(filled_quantity: quantity_to_be_filled, filled_state: @filled_state)
            ##Checking and updating filled state in fillings on quantity update
            #kit_fill_state = find_kit_current_filled_state(kit_filling_update)
            #kit_filling_update.update_attributes(:filled_state => kit_fill_state)
            @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:kit_filling_id],id).first
            if @kit_filling_histories_report.present?
              if @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "S"
                required_qty = "S"
              elsif @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "E"
                required_qty = "WL"
              elsif @kit_filling_histories_report.demand_qty == "WL" && @kit_filling_details.filled_quantity == "WL"
                required_qty = "E"
              else
                required_qty = @kit_filling_histories_report.demand_qty.to_i - @kit_filling_details.filled_quantity.to_i
              end
              @kit_filling_histories_report.update_attribute(:filled_qty, required_qty)
            end
          end
          respond_to do |format|
            format.js  { }
          end
        else
          redirect_to main_app.unauthorized_url
        end
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
  end
end