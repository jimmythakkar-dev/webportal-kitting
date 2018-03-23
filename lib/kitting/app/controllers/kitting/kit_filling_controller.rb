require_dependency "kitting/application_controller"

module Kitting
  class KitFillingController < ApplicationController

    layout "kitting/fit_to_compartment", :only => [ :create_filling_show, :show, :edit, :kit_filling_edit ]
    before_filter :get_acess_right
    protect_from_forgery
    include KitsHelper
    include Kitting::KitCopiesHelper

    def index
      if params[:kit_number_search]
        @kit_copy = Kitting::KitCopy.find_by_kit_version_number(params[:kit_number_search].try(:strip))
        if @kit_copy
          @kits_filling = Kitting::KitFilling.where(:kit_copy_id => @kit_copy.id,:flag => true,:customer_id => current_company, :kit_work_order_id => nil).paginate(:page => params[:page], :per_page => 100).order('updated_at desc')
        else
          @kits_filling = Kitting::KitFilling.where(:flag => true,:customer_id => current_company, :kit_work_order_id => nil).paginate(:page => params[:page], :per_page => 100).order('updated_at desc')
        end
      else
        @kits_filling = Kitting::KitFilling.where(:flag => true,:customer_id => current_company, :kit_work_order_id => nil).paginate(:page => params[:page], :per_page => 100).order('updated_at desc')
      end
    end

    def show
      @kit_filling = Kitting::KitFilling.find(params[:id])
    end

    def kit_status
      # check version of the kit copies and kit BOM
      if params[:id]
        @kit_copy = KitCopy.where('id= ?', params[:id])
        @kit_copy_status = @kit_copy.first.version_status
        @kit_status = @kit_copy.first.kit.current_version
        if !@kit_copy_status.nil? && !@kit_status.nil?
          if @kit_copy_status != @kit_status
            @message = "Kit changed"
            render json: @message
          else
            @message = "Kit Not changed"
            render json: @message
          end
        else
          @message = "No kit"
          render json: @message
        end
      end
    end

    #it will show the data change in Kit BOM while filling that particular kit
    def change_data
      if request.xhr?
        @kit_copy = KitCopy.where('id= ?', params[:id])
        @kit = @kit_copy.first.kit
        @bom_version = @kit.current_version
        @copy_version = @kit_copy.first.version_status
        @change_data = invoke_webservice method: "get", action: "kitDelta", query_string: {kitBomVersion: @bom_version, kitNo: @kit.kit_number, kitCopyVersion: @copy_version }
      end
    end

    #print the changed data in kit BOM
    def print_change_data
      @change_data = JSON.parse(params["change_data"])
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

    def kit_copy_status_update
      @kit_copy = KitCopy.where('id= ?', params[:id])
      @kit_current_version = @kit_copy.first.kit.current_version
      respond_to do |format|
        if @kit_copy.first.update_attribute("version_status",@kit_current_version)
          format.html do
            render :nothing => true
          end

        end
      end
    end

    # it will create the new record in kit filling tabel and kit filling details table

    def create_filling_show
      @check_filling = Kitting::KitFilling.find_by_kit_copy_id_and_flag(params[:id],1)
      @location_name = Kitting::KitCopy.find_by_id(params[:id]).location.name
      unless @check_filling && params[:kit_filling_id].blank?
        @loc = Kitting::Location.where('name LIKE ?', "Picking Queue")
        Kitting::KitCopy.find_by_id(params[:id]).update_attribute("location_id",@loc.first.id)
        if params[:received].nil?
          @kit_filling = {kit_copy_id: params[:id],flag: 1,created_by: current_user }
        else
          @kit_filling = {kit_copy_id: params[:id],created_by: current_user, received: params[:received]}
        end
        @kit_filling = current_customer.kit_fillings.create(@kit_filling)
        @kit_filling = Kitting::KitFilling.find(@kit_filling.id)
        @kit_filling.kit_copy.kit.cup_parts.where(:commit_status => true,:status => 1).map do |cup_part|
          if cup_part.in_contract
            filled_qty = (cup_part.demand_quantity == "Water-Level"  || cup_part.demand_quantity == "WL") ? "E" : 0
            @kit_filling_details = { kit_filling_id: @kit_filling.id, cup_part_id: cup_part.id,filled_quantity: filled_qty, filled_state: 'E'}
            @kit_filling_details = Kitting::KitFillingDetail.create(@kit_filling_details)

            #Checking and updating filled state in fillings on quantity update
            kit_fill_state = find_kit_current_filled_state(@kit_filling)
            @kit_filling.update_attributes(:filled_state => kit_fill_state)
            @filling_histories_details = {:kit_number=> @kit_filling.try(:kit_copy).try(:kit).try(:kit_number),:kit_copy_number=>@kit_filling.try(:kit_copy).try(:kit_version_number),:customer_number=>@kit_filling.try(:customer).try(:cust_no),:cup_no=>cup_part.try(:cup).try(:cup_number),:part_number=>cup_part.try(:part).try(:part_number),:demand_qty=>cup_part.demand_quantity,:filled_qty=>filled_qty,:filling_date=>@kit_filling.created_at,:created_by=>@kit_filling.try(:customer).try(:user_name),:kit_filling_id=>@kit_filling.id,:cup_part_id=>cup_part.id,:cup_part_status=>cup_part.status,:cup_part_commit_status=>cup_part.commit_status}
            @kit_filling_histories_report = Kitting::KitFillingHistoryReport.create(@filling_histories_details)
          end
        end
      else
        @kit_filling = @check_filling
      end
      @kit_copy = Kitting::KitCopy.find(params[:id])
    end

    # while clicking on fill kit link on kit processing page it will create new filling

    def kit_filling_create
      @kit_filling_details = Kitting::KitFilling.find(params[:kit_filling_id])
      @kit_filling = {location_id: params[:kit_filling_location_id], filled_state: params[:filled_state]}
      respond_to do |format|
        if @kit_filling_details.update_attributes(@kit_filling)
          format.html  { redirect_to(kit_filling_index_path,:notice => 'Kit filling is successfully updated.') }
          format.json  { head :no_content }
        else
          format.html  { render :action => 'show', flash.now[:error] => 'Error while filling the Kit' }
        end
      end
    end

    # add filling quantity on create filling page
    def edit
      @kit_filling = Kitting::KitFilling.find_by_id(params[:id])
      @type = @kit_filling.kit_copy.present? ? "LEAN" : "AD HOC"
      @kit_media_type = @type == "AD HOC" ? @kit_filling.kit_work_order.kit.kit_media_type.kit_type : @kit_filling.kit_copy.kit.kit_media_type.kit_type
      @kit_copy_status = @type == "AD HOC" ? @kit_filling.kit_work_order.kit.status : @kit_filling.kit_copy.status
      if @type != "AD HOC" && @kit_copy_status == 6
        @updated_by = @kit_filling.kit_copy.kit_status_details.last.updated_by
        @updated_at = @kit_filling.kit_copy.kit_status_details.last.updated_at
      end
      if @kit_media_type == "multi-media-type"
        @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_copy.kit.id,true).sort
        mmt_kit_ids = @multi_media_kits.map {|m| m.id}
        kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
        @kit = Kitting::Kit.find(kit_id)
      else
        @kit = @type == "AD HOC" ? @kit_filling.kit_work_order.kit : @kit_filling.kit_copy.kit
      end

      @status = @kit_filling.rbo_status == "Revoked" rescue false
      if @kit_filling.present? and @status
        @location_name = @type == "AD HOC" ? @kit_filling.kit_work_order.location.name : @kit_filling.kit_copy.location.name
      else
        notice = get_revision_message params[:id], "Kitting::KitFilling"
        respond_to do |format|
          format.html { redirect_to kit_copies_path, alert: notice }
          format.json { head :no_content }
        end
      end
    end

    # it will update the filled kit status and sent kit to ship/invoice or send to bailment or SOS queue

    def update
      @check_rbo_status = Kitting::KitFilling.find_by_id(params[:id])
      @status = @check_rbo_status.rbo_status == "Revoked" rescue false
      @type = @check_rbo_status.kit_copy.present? ? "LEAN" : "AD HOC" rescue false
      # to prevent other user from filling the same kit at once
      if @type=="AD HOC"
        @kit_filling = @check_rbo_status || Kitting::KitFilling.find_by_id(params[:id])
        kit_number = @kit_filling.try(:kit_work_order).try(:kit).try(:kit_number)
        customer_kit_part_number = @kit_filling.try(:kit_work_order).try(:kit).try(:customer_kit_part_number)
        kit_work_order = @kit_filling.try(:kit_work_order)
        work_order = @kit_filling.try(:kit_work_order).try(:work_order)
        location_name = find_location(params[:kit_filling][:location])
        filling_arr = Array.new
        partial_array = Array.new
        @kit_filling.kit_filling_details.each do |kit_details|
          filling_arr << kit_details.filled_state
          partial_array << kit_details if (kit_details.filled_state == "P" || kit_details.filled_state == "E" )
        end
        if filling_arr.include?('P')
          filling_state = 2
        elsif filling_arr.uniq.count > 1
          filling_state = 2
        elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('F')))
          filling_state = 1
        elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('E')))
          filling_state = 0
        end
        if partial_array.length > 0
          @order = Order.find_or_create_by_kit_filling_id(kit_filling_id: @kit_filling.id,order_number: work_order.order_number, order_type: "SOS", order_status: filling_state.to_s, customer_name: current_customer.user_name, customer_number: current_user, project_id: work_order.serial_number, station_name: work_order.stage,discharge_point_name: "N/A", kit_part_number: customer_kit_part_number, created_by: current_customer.user_name, updated_by: current_customer.user_name, due_date: DateTime.now + 5.days) unless @kit_filling.order.present?
          new_kit_location = Kitting::Location.find_by_name("NEW KIT QUEUE")
          partial_array.each do |kfd|
            req_quantity = 0.0
            if kfd.filled_quantity == 'WL'
              req_quantity = 'E'
            elsif kfd.filled_quantity == 'S'
              req_quantity = 'S'
            elsif kfd.filled_quantity == 'E'
              req_quantity = 'WL'
            else
              req_quantity = ((kfd.cup_part.demand_quantity.to_f) - (kfd.filled_quantity.to_f)).round(2)
            end
            opd = @order.order_part_details.find_or_create_by_kit_filling_detail_id(kit_filling_detail_id: kfd.id,part_number: kfd.cup_part.part.part_number,
                                                                              quantity: req_quantity, fulfilment_date_time: DateTime.now,
                                                                              uom: kfd.cup_part.uom, filled_state: kfd.filled_state,
                                                                              reason_code: 'KIT SHORT',location_id: new_kit_location.id)
            if opd.present?
              opd.update_attributes(:pack_id => "CP-#{opd.id}")
            end
          end
        end
        respond_to do |format|
          #  FOR SHIP / INVOICE QUEUE
          if location_name =="Ship/Invoice"
            if @kit_filling.update_attributes( flag: false ,rbo_status: "Invoked", filled_state: filling_state, location_id: params[:kit_filling][:location].to_i) && kit_work_order.update_attribute(:location_id, params[:kit_filling][:location].to_i) && Kitting::KitOrderFulfillment.create(kit_filling_id: @kit_filling.id, kit_work_order_id: kit_work_order.id, kit_number: customer_kit_part_number, user_name: current_customer.user_name, cust_name: current_customer.cust_name, cust_no: current_customer.cust_no, order_no_received: work_order.order_number,filled_state: filling_state, location_name: find_location(params[:kit_filling][:location].to_i))
              # @check_rbo_status.update_attribute("rbo_status","Invoked")
              # ------------ Added Log generation code ------------
              Rails.logger.info "Kit Completed Successfully on #{Time.now}"
              # ---------------------------------------------------
              flash[:success] = "Kit Filling Completed for <b>#{customer_kit_part_number}</b>. <br> Order No : #{work_order.order_number} , By : #{session["user_name"]}"
              format.html { redirect_to work_order_fillings_kit_work_orders_path }
              format.json { head :no_content }
            else
              # ------------ Added Log generation code ------------
              Rails.logger.info "***Kit Completed fail while updating DB on #{Time.now}"
              # ---------------------------------------------------
              @check_rbo_status.update_attribute("rbo_status","Revoked")
              format.html { render action: "edit" }
              format.json { render json: @kit_filling.errors }
            end
          else
            #  FOR SOS QUEUE
              if @kit_filling.update_attributes(filled_state: filling_state, location_id: params[:kit_filling][:location].to_i) && kit_work_order.update_attributes(location_id: params[:kit_filling][:location].to_i)
                flash[:alert]="Kit : <b>#{customer_kit_part_number}</b> <br/> Move To : #{ find_location(params[:kit_filling][:location].to_i) }, By : #{session["user_name"]}."
                @check_rbo_status.update_attribute("rbo_status","Revoked")
                format.html { redirect_to work_order_fillings_kit_work_orders_path }
                format.json { head :no_content }
              else
                @check_rbo_status.update_attribute("rbo_status","Revoked")
                format.html { render action: "edit" }
                format.json { render json: @kit_filling.errors }
              end
          end
        end
      else
        if @check_rbo_status.present? and @status
          @location_name = @check_rbo_status.kit_copy.present? ? @check_rbo_status.kit_copy.location.present? ? @check_rbo_status.kit_copy.location.name  : "" : ""
          @kit_filling = @check_rbo_status
          @kit_copy_status = @kit_filling.kit_copy.status
          if @kit_copy_status == 6
            @updated_by = @kit_filling.kit_copy.kit_status_details.last.updated_by
            @updated_at = @kit_filling.kit_copy.kit_status_details.last.updated_at
          end
          if @kit_filling.kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
            @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_copy.kit.id,true).sort
            mmt_kit_ids = @multi_media_kits.map {|m| m.id}
            kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id].to_i) ? params[:mmt_kit_id] : mmt_kit_ids.first
            @kit = Kitting::Kit.find(kit_id)
          else
            @kit = @kit_filling.kit_copy.kit
          end

          if check_filled_quantity(@kit_filling)
            if check_order_for_ship(@kit_filling,params[:kit_order_number_list])
              @check_order_status = Kitting::KitOrderFulfillment.find_by_kit_filling_id(params[:id])
              if @check_rbo_status.rbo_status == "Revoked" and @check_order_status.blank?
                @check_rbo_status.update_attribute("rbo_status","Invoking")
                #*****************************************************************#
                @kit_filling = Kitting::KitFilling.find(params[:id])
                @kit_copy =  @kit_filling.kit_copy
                #kit_copy_location = Kitting::Location.where('name LIKE ?', "%KIT%")
                kit_number = @kit_filling.try(:kit_copy).try(:kit).try(:kit_number)
                location_name = find_location(params[:kit_filling][:location_id])
                kit_copy_number = @kit_copy.kit_version_number.split('-').last
                #-------------Find Kit Filled State--------------------
                filling_arr = Array.new
                @kit_filling.kit_filling_details.each do |kit_details|
                  filling_arr << kit_details.filled_state
                end
                if filling_arr.include?('P')
                  filling_state = 2
                elsif filling_arr.uniq.count > 1
                  filling_state = 2
                elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('F')))
                  filling_state = 1
                elsif ((filling_arr.uniq.count == 1 && filling_arr.include?('E')))
                  filling_state = 0
                end
                #--------------------------------------------------------

                if(location_name == 'Send to Stock' || (location_name == 'Ship/Invoice' && params[:kit_order_number_list].present?))
                  ######################------------- ORDER COMPLETION START (SEND TO CARDEX )-------------------- #####################
                  @bailment_info = invoke_webservice method: "get", action: "bailmentInfo", query_string: { custNo: current_user,partNo:kit_number ,mailFlag:"N" }
                  @bailment_status = @bailment_info["copyNums"].include?("COPY".concat(kit_copy_number))
                  if location_name == "Send to Stock" && params[:kit_order_number] == "Send to Bailment" && ApplicationController.helpers.get_customer_list(current_customer.cust_no).first.prevent_kit_copy? && @bailment_status
                    @check_rbo_status.update_attribute("rbo_status","Revoked")
                    flash.now[:error] = "#{@bailment_info["copyNums"].select { |kit_copy| kit_copy== "COPY".concat(kit_copy_number) }.count} Kit Copy of this KIT #{kit_number} already present in Inventory. "
                    render 'edit', layout: 'kitting/fit_to_compartment'
                  else
                    if params[:kit_order_number].blank?
                      @kit_complete = invoke_webservice method: "get", action: "kitComplete",query_string: {custNo: current_user, userId: session["user_name"], kitId: kit_number,copyNo: kit_copy_number, direction: 'CARDEX'}
                    else
                      @kit_complete = invoke_webservice method: "get", action: "kitComplete",query_string: {custNo: current_user, userId: session["user_name"], kitId: kit_number,copyNo: kit_copy_number, orderNo: params[:kit_order_number], scancode: params[:kit_scan_code]}
                    end
                    if @kit_complete['errCode'] == '0' || @kit_complete['errCode'] == '2'
                      respond_to do |format|
                        # ------------ Added Log generation code ------------
                        Rails.logger.info "Kit Complete RBO Success on #{Time.now} with this parameters: "+ params.inspect
                        # ---------------------------------------------------
                        if @kit_filling.update_attributes( flag: false ,rbo_status: "Invoked", filled_state: filling_state, location_id: params[:kit_filling][:location_id].to_i) && @kit_copy.update_attribute(:location_id, params[:kit_filling][:location_id].to_i) && Kitting::KitOrderFulfillment.create(kit_filling_id: @kit_filling.id, kit_copy_number: @kit_filling.kit_copy.kit_version_number, kit_number: @kit_filling.kit_copy.kit.kit_number, user_name: current_customer.user_name, cust_name: current_customer.cust_name, cust_no: current_customer.cust_no, order_no_closed: params[:kit_order_number],scancode_closed: params[:kit_scan_code], order_no_received: params[:kit_order_number_list],scancode_received:params[:kit_scan_code_list], box_id: @kit_complete["boxId"], filled_state: filling_state, location_name: find_location(params[:kit_filling][:location_id].to_i))
                          # @check_rbo_status.update_attribute("rbo_status","Invoked")
                          # ------------ Added Log generation code ------------
                          Rails.logger.info "Kit Completed Successfully on #{Time.now}"
                          # ---------------------------------------------------
                          format.html { redirect_to kit_copies_path(alert: " Kit Filling Completed for <b>#{@kit_copy.kit_version_number}</b>. <br>  #{params[:kit_order_number] ? "Order No : #{params[:kit_order_number]} , ScanCode : #{params[:kit_scan_code]}, Box Id : #{@kit_complete["boxId"]}" : "Direction : CARDEX"} , By : #{session["user_name"]}".html_safe) }
                          format.json { head :no_content }
                        else
                          # ------------ Added Log generation code ------------
                          Rails.logger.info "***Kit Completed fail while updating DB on #{Time.now}"
                          # ---------------------------------------------------
                          @check_rbo_status.update_attribute("rbo_status","Revoked")
                          format.html { render action: "edit" }
                          format.json { render json: @kit_filling.errors }
                        end
                      end
                    else
                      if @kit_complete['errCode'] == ''
                        @check_rbo_status.update_attribute("rbo_status","Revoked")
                        flash.now[:error] = 'ErrCode is Empty'
                      else
                        @check_rbo_status.update_attribute("rbo_status","Revoked")
                        flash.now[:error] = @kit_complete['errMsg']
                      end
                      render 'edit', layout: 'kitting/fit_to_compartment'
                    end
                  end
                  ######################------------- ORDER COMPLETION STOP (SEND TO CARDEX)-------------------- #####################
                else
                  respond_to do |format|
                    if @kit_filling.update_attributes(filled_state: filling_state, location_id: params[:kit_filling][:location_id].to_i) &&
                        @kit_copy.update_attributes(location_id: params[:kit_filling][:location_id].to_i)
                      format.html { redirect_to kit_filling_index_path(alert: "Kit : <b>#{@kit_copy.kit_version_number}</b> <br/> Move To : #{ find_location(params[:kit_filling][:location_id].to_i) }, By : #{session["user_name"]}.".html_safe)}
                      format.json { head :no_content }
                      @check_rbo_status.update_attribute("rbo_status","Revoked")
                    else
                      @check_rbo_status.update_attribute("rbo_status","Revoked")
                      format.html { render action: "edit" }
                      format.json { render json: @kit_filling.errors }
                    end
                  end
                end
                #*****************************************************************#
              else
                flash[:error] = "Kit you're trying to fill is already Invoiced / Sent to Bailment by another User. Please verify "
                #flash[:error] = "This Kit Filling have a order or Some one else is trying to create a order for this. Contact your KLX Administrator."
                redirect_to kit_copies_path
              end
            else
              flash.now[:error] = "No Open order exist for ship/invoice, Please select other queue"
              render 'edit', layout: 'kitting/fit_to_compartment'
            end
          else
            flash.now[:error] = "Please fill all the cups/compartments for sending to stock"
            render 'edit', layout: 'kitting/fit_to_compartment'
          end
        else
          notice = get_revision_message params[:id], "Kitting::KitFilling"
          respond_to do |format|
            format.html { redirect_to kit_copies_path, alert: notice }
            format.json { head :no_content }
          end
        end
      end
    end

    # to change the filled quantity in kit filling
    # also change the tern count of part for turn count report

    def kit_filling_edit
      if params[:member_data].present?
        params[:kit_filling_id] = params[:member_data][:kit_filling_id]
      end
      @kit_filling = Kitting::KitFilling.find_by_id(params[:kit_filling_id])
      if params[:cup_number_count]
        params[:cup_number_count] = params[:cup_number_count].to_i
      end
      @type = @kit_filling.kit_copy.nil? ? "AD HOC" : "LEAN"
      if @type == "AD HOC"
        @kit_media_type = @kit_filling.kit_work_order.kit.kit_media_type.kit_type
        if @kit_media_type == "multi-media-type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_work_order.kit.id,true).sort
          mmt_kit_ids = @multi_media_kits.map {|m| m.id}
          kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id]) ? params[:mmt_kit_id] : mmt_kit_ids.first
          @kit = Kitting::Kit.find(kit_id)
        else
          @kit = @kit_filling.kit_work_order.kit
        end
      else
        @kit_media_type = @kit_filling.kit_copy.kit.kit_media_type.kit_type
        if @kit_media_type == "multi-media-type"
          @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_copy.kit.id,true).sort
          mmt_kit_ids = @multi_media_kits.map {|m| m.id}
          kit_id = params[:mmt_kit_id] && mmt_kit_ids.include?(params[:mmt_kit_id]) ? params[:mmt_kit_id] : mmt_kit_ids.first
          @kit = Kitting::Kit.find(kit_id)
        else
          @kit = @kit_filling.kit_copy.kit
        end
      end

      @status = @kit_filling.rbo_status == "Revoked" rescue false
      if @kit_filling.present? and @status
        # for binder kit media type
        if params[:member_data].present?
          ################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
          if @type == "AD HOC"
            check_approved_kit_and_update_accordingly(@kit_filling.kit_work_order.kit,params[:member_data][:kit_filling_id])
          else
            @kit = Kitting::Kit.find_by_kit_number_and_status(params[:member_data][:kit_number],1)
            check_approved_kit_and_update_accordingly(@kit_filling.kit_copy.kit,params[:member_data][:kit_filling_id])
          end
          ################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
          @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?', params[:member_data][:kit_filling_id],params[:member_data][:cup_part_id] ).first
          if params[:filled_qty].present?
            filled_qty = convert_index_to_qty_for_wl(params[:filled_qty])
          else
            filled_qty = convert_index_to_qty_for_wl(params[:filled_quantity][:qty])
          end
          if @type != "AD HOC" && filled_qty.to_i != 0
            filled_qty = filled_qty.to_i
          end
          demand_quantity = find_cup_part_demand_qty(params[:member_data][:cup_part_id])
          filled_quantity = filled_qty
          @filled_state = find_filled_state(demand_quantity, filled_quantity,true)
          @current_filled_quantity = @kit_filling_details.filled_quantity
          @kit_filling_details.update_attributes(filled_quantity: filled_qty, filled_state: @filled_state)
          #Checking and updating filled state in fillings on quantity update
          kit_fill_state = find_kit_current_filled_state(@kit_filling)
          @kit_filling.update_attributes(:filled_state => kit_fill_state)
          @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:member_data][:kit_filling_id],params[:member_data][:cup_part_id]).first
          @kit_filling_histories_report.update_attribute(:filled_qty, @kit_filling_details.filled_quantity)
          if @current_filled_quantity != filled_qty && @type != "AD HOC"
            if (filled_qty == "0" ||  filled_qty == "E")
              cup_id = @kit_filling_details.cup_part.cup_id
              cup_number = Kitting::Cup.find(cup_id).try(:cup_number)
              if @kit_filling_details.turn_count == 0
                @kit_filling_details.turn_count = @kit_filling_details.turn_count
              else
                @kit_filling_details.turn_count = @kit_filling_details.turn_count - 1
                turn_copy_number = @kit_filling_details.kit_filling.kit_copy.kit_version_number.split("-").last
                if @multi_media_kits
                  box_number = box_number || @multi_media_kits.index(@multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
                  @decrease_count = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number =? AND cup_no = ? AND part_number = ? ",
                                                                    params[:member_data][:kit_number],box_number, cup_number,
                                                                    @kit_filling_details.cup_part.part.part_number).first
                else
                  @decrease_count = Kitting::TurnReportDetail.where("kit_number = ? AND  cup_no = ? AND part_number = ? ",
                                                                    params[:member_data][:kit_number], cup_number,
                                                                    @kit_filling_details.cup_part.part.part_number).first
                end
                if @decrease_count.present?
                  turn_column = "turns_copy" + turn_copy_number
                  @current_count = @decrease_count.send(turn_column)
                  @decrease_count.update_attribute(turn_column, @current_count - 1)
                end
              end
            else
              turn_copy_number = @kit_filling_details.kit_filling.kit_copy.kit_version_number.split("-").last
              if @multi_media_kits
                box_number = box_number || @multi_media_kits.index(@multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
                @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number =? AND cup_no = ?  AND part_number = ? AND (created_at between ? and ?)",
                                                                     params[:kit_number], box_number,params[:cup_number_count], @kit_filling_details.cup_part.part.part_number,
                                                                     Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
              else
                @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND cup_no = ?  AND part_number = ? AND (created_at between ? and ?)",
                                                                     params[:kit_number],params[:cup_number_count], @kit_filling_details.cup_part.part.part_number,
                                                                     Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
              end
              description = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:description)
              kit_media_type = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:kit_media_type).try(:name)
              part_description = @kit_filling_details.try(:cup_part).try(:part).try(:name)
              if @turn_count_record.blank?
                Kitting::TurnReportDetail.create(:kit_number => params[:kit_number], :kit_description => description,
                                                 :cup_no => params[:cup_number_count],:part_number => @kit_filling_details.cup_part.part.part_number,
                                                 :"turns_copy#{turn_copy_number}".to_sym => 1, :kit_media_type => kit_media_type, :part_description => part_description, :cust_no => session[:customer_number], :sub_kit_number => box_number)
              else
                if @multi_media_kits
                  box_number = box_number || @multi_media_kits.index(@multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
                  @increase_count = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number =? AND cup_no = ? AND part_number = ?",
                                                                    params[:kit_number],box_number,params[:cup_number_count],
                                                                    @kit_filling_details.cup_part.part.part_number).first
                else
                  @increase_count = Kitting::TurnReportDetail.where("kit_number = ?  AND cup_no = ? AND part_number = ?",
                                                                    params[:kit_number],params[:cup_number_count],
                                                                    @kit_filling_details.cup_part.part.part_number).first
                end

                turn_column = "turns_copy" + turn_copy_number
                @current_count = @increase_count.send(turn_column)
                if @kit_filling_details.turn_count == 0
                  @increase_count.update_attribute(turn_column, @current_count + 1)
                else
                  @increase_count.update_attribute(turn_column, @current_count)
                end
                @kit_filling_details.turn_count = 1
              end
            end
            @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
          end
          respond_to do |format|
            format.js {}
          end
        else
          # for other than binder kit media type
          ################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
          @kit= Kitting::Kit.find_by_kit_number_and_status(params[:kit_number],1)
          check_approved_kit_and_update_accordingly(@kit_filling.kit_copy.kit,params[:kit_filling_id])
          ################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
          params[:cup_part_id].each_with_index do |id,index|
            @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?', params[:kit_filling_id],id ).first
            demand_quantity = find_cup_part_demand_qty(id)
            filled_quantity = params[:filled_quantity][index]
            @filled_state = find_filled_state(demand_quantity, filled_quantity)
            @current_filled_quantity = @kit_filling_details.filled_quantity
            @kit_filling_details.update_attributes(filled_quantity: params[:filled_quantity][index], filled_state: @filled_state)
            #Checking and updating filled state in fillings on quantity update
            kit_fill_state = find_kit_current_filled_state(@kit_filling)
            @kit_filling.update_attributes(:filled_state => kit_fill_state)
            @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:kit_filling_id],id).first
            @kit_filling_histories_report.update_attribute(:filled_qty, @kit_filling_details.filled_quantity)
            unless @current_filled_quantity == params[:filled_quantity][index]
              kit_id = Kitting::Cup.find_by_id(params[:kit_cup_number]).kit.id
              if @multi_media_kits
                box_number = box_number || @multi_media_kits.index(@multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
              end
              if (params[:filled_quantity][index] == "0" ||  params[:filled_quantity][index] == "E")
                if @kit_filling_details.turn_count == 0
                  @kit_filling_details.turn_count = @kit_filling_details.turn_count
                else
                  @kit_filling_details.turn_count = @kit_filling_details.turn_count - 1
                  turn_copy_number = @kit_filling_details.kit_filling.kit_copy.kit_version_number.split("-").last
                  if @multi_media_kits
                    @decrease_count = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ?",
                                                                      params[:kit_number], box_number, params[:cup_number_count],
                                                                      @kit_filling_details.cup_part.part.part_number).last
                  else
                    @decrease_count = Kitting::TurnReportDetail.where("kit_number = ?  AND cup_no = ? AND part_number = ?",
                                                                      params[:kit_number], params[:cup_number_count],
                                                                      @kit_filling_details.cup_part.part.part_number).last
                  end
                  if @decrease_count.present?
                    turn_column = "turns_copy" + turn_copy_number
                    @current_count = @decrease_count.send(turn_column)
                    @decrease_count.update_attribute(turn_column, @current_count - 1)
                  end
                end
              else
                turn_copy_number = @kit_filling_details.kit_filling.kit_copy.kit_version_number.split("-").last
                if @multi_media_kits
                  @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)",
                                                                       params[:kit_number], box_number, params[:cup_number_count], @kit_filling_details.cup_part.part.part_number,
                                                                       Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                else
                  @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ?  AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)",
                                                                       params[:kit_number], params[:cup_number_count], @kit_filling_details.cup_part.part.part_number,
                                                                       Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                end
                description = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:description)
                kit_media_type = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:kit_media_type).try(:name)
                part_description = @kit_filling_details.try(:cup_part).try(:part).try(:name)
                if @turn_count_record.blank?

                  Kitting::TurnReportDetail.create(:kit_number => params[:kit_number], sub_kit_number: box_number, :kit_description => description,
                                                   :cup_no => params[:cup_number_count],:part_number => @kit_filling_details.cup_part.part.part_number,
                                                   :"turns_copy#{turn_copy_number}".to_sym => 1, :kit_media_type => kit_media_type, :part_description => part_description, :cust_no => session[:customer_number])
                else
                  if @multi_media_kits
                    @increase_count = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ?",
                                                                      params[:kit_number],box_number , params[:cup_number_count],
                                                                      @kit_filling_details.cup_part.part.part_number).last
                  else
                    @increase_count = Kitting::TurnReportDetail.where("kit_number = ?  AND cup_no = ? AND part_number = ?",
                                                                      params[:kit_number], params[:cup_number_count],
                                                                      @kit_filling_details.cup_part.part.part_number).last
                  end
                  turn_column = "turns_copy" + turn_copy_number
                  @current_count = @increase_count.send(turn_column)
                  if @kit_filling_details.turn_count == 0
                    @increase_count.update_attribute(turn_column, @current_count + 1)
                  else
                    @increase_count.update_attribute(turn_column, @current_count)
                  end
                  @kit_filling_details.turn_count = 1
                end
              end
              @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
            end
          end
          respond_to do |format|
            format.html  { redirect_to(edit_kit_filling_path(params[:kit_filling_id],mmt_kit_id: params[:mmt_kit_id]),:notice => "Cup filling updated Successfully.") }
            format.json  { head :no_content }
          end
        end
      else
        notice = get_revision_message params[:kit_filling_id], "Kitting::KitFilling"
        respond_to do |format|
          format.html { redirect_to kit_copies_path, alert: notice }
          format.json { head :no_content }
        end
      end
    end

    # fill all cup with required quantity
    # also change the tern count of part for turn count report

    def fill_all_cups
      @kit_filling = Kitting::KitFilling.find_by_id(params[:id])
      status = @kit_filling.rbo_status == "Revoked" rescue false
      if @kit_filling.present? and status
        if @kit_filling.kit_copy.nil? && @kit_filling.kit_work_order.present?
          @kit_filling.kit_filling_details.each do |kf|
            kf.update_attributes(:filled_quantity => kf.cup_part.try(:demand_quantity),:filled_state => "F")
            kit_filling_history= Kitting::KitFillingHistoryReport.find_by_kit_filling_id_and_cup_part_id_and_kit_work_order_id(params[:id],kf.cup_part.id,kf.kit_filling.kit_work_order_id)
            kit_filling_history.update_attribute(:filled_qty, kf.cup_part.try(:demand_quantity))
          end
          @kit_filling.update_attribute("filled_state",1)
        else
          #################### START CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY #################
          @kit= Kitting::KitFilling.find_by_id(params[:id]).kit_copy.kit
          check_approved_kit_and_update_accordingly(@kit,params[:id])
          #################### STOP CODE TO CHECK APPROVED CUPS AND MODIFY ACCORDINGLY ##################
          if @kit_filling.kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
            @multi_media_kits = Kitting::Kit.find_all_by_parent_kit_id_and_commit_status(@kit_filling.kit_copy.kit.id,true).sort
            cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id),:commit_status => true)
          else
            cups =  Kitting::KitFilling.find(params[:id]).try(:kit_copy).try(:kit).try(:cups).where(:commit_status => true)
          end
          cups.map! do |cup|
            cup.try(:cup_parts).where('commit_status = ? and status = ? ',true, 1).map! do |cup_part|
              if cup_part.in_contract
                @kit_filling_details =  Kitting::KitFillingDetail.where('kit_filling_id = ? and cup_part_id = ?',params[:id],cup_part).first
                @kit_filling_histories_report = Kitting::KitFillingHistoryReport.where('kit_filling_id = ? and cup_part_id = ?',params[:id],cup_part).first
                demand_quantity = find_cup_part_demand_qty(cup_part)
                filled_quantity = cup_part.try(:demand_quantity)
                @filled_state = find_filled_state(demand_quantity, filled_quantity)
                @current_filled_quantity = @kit_filling_details.filled_quantity
                @kit_filling_details.update_attributes(filled_quantity: cup_part.try(:demand_quantity), filled_state: @filled_state) if cup_part.status && cup_part.in_contract
                @kit_filling_histories_report.update_attribute(:filled_qty, cup_part.try(:demand_quantity))
                kit_number = @kit_filling_details.kit_filling.kit_copy.kit.kit_number
                kit_id = cup_part.cup.kit.id
                if @multi_media_kits
                  box_number = box_number || @multi_media_kits.index(@multi_media_kits.select { |kit| kit.id == kit_id}.first) + 1
                end
                description = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:description)
                kit_media_type = @kit_filling_details.try(:kit_filling).try(:kit_copy).try(:kit).try(:kit_media_type).try(:name)
                part_description = @kit_filling_details.try(:cup_part).try(:part).try(:name)
                turn_copy_number = @kit_filling_details.kit_filling.kit_copy.kit_version_number.split("-").last
                cup_id = @kit_filling_details.cup_part.cup_id
                cup_number = cup.cup_number
                if @multi_media_kits
                  @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)", kit_number, box_number,cup_number, @kit_filling_details.cup_part.part.part_number, Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                else
                  @turn_count_record = Kitting::TurnReportDetail.where("kit_number = ?  AND cup_no = ? AND part_number = ? AND (created_at between ? and ?)", kit_number,cup_number, @kit_filling_details.cup_part.part.part_number, Time.now.in_time_zone.beginning_of_day, Time.now.in_time_zone.end_of_day).first
                end
                if @turn_count_record.blank?
                  Kitting::TurnReportDetail.create(:kit_number => kit_number, :sub_kit_number => box_number, :kit_description => description, :cup_no => cup_number,:part_number => @kit_filling_details.cup_part.part.part_number, :"turns_copy#{turn_copy_number}".to_sym => 1, :kit_media_type => kit_media_type, :part_description => part_description, :cust_no => session[:customer_number])
                else
                  if @multi_media_kits
                    @increase_count = Kitting::TurnReportDetail.where("kit_number = ? AND sub_kit_number = ? AND cup_no = ? AND part_number = ?", kit_number,box_number, cup_number, @kit_filling_details.cup_part.part.part_number).last
                  else
                    @increase_count = Kitting::TurnReportDetail.where("kit_number = ? AND  cup_no = ? AND part_number = ?", kit_number, cup_number, @kit_filling_details.cup_part.part.part_number).last
                  end
                  turn_column = "turns_copy" + turn_copy_number
                  @current_count = @increase_count.send(turn_column)
                  if @kit_filling_details.turn_count == 0
                    @increase_count.update_attribute(turn_column, @current_count + 1)
                  else
                    @increase_count.update_attribute(turn_column, @current_count)
                  end
                end
                @kit_filling_details.turn_count = 1
                @kit_filling_details.update_attribute(:turn_count, @kit_filling_details.turn_count)
              end
            end
          end
          kit_filling_update = Kitting::KitFilling.find_by_id(params[:id])
          #Checking and updating filled state in fillings on quantity update
          kit_fill_state = find_kit_current_filled_state(kit_filling_update)
          kit_filling_update.update_attributes(:filled_state => kit_fill_state)
        end
        respond_to do |format|
          format.html  { redirect_to(edit_kit_filling_path(params[:id]),:notice => "Cup filling updated Successfully.") }
          format.json  { head :no_content }
        end
      else
        notice = get_revision_message params[:id], "Kitting::KitFilling"
        respond_to do |format|
          format.html { redirect_to kit_copies_path, alert: notice }
          format.json { head :no_content }
        end
      end
    end

    # empty filled quantity

    def destroy
      @kit_filling = Kitting::KitFilling.find_by_id(params[:id])
      status = @kit_filling.rbo_status == "Revoked" rescue false
      @loc = Kitting::Location.where('name LIKE ?', params[:location_name])
      if @loc.empty?
        flash[:alert] = "Cannot Cancel Kit Filling without Location"
        redirect_to kit_filling_index_path
      else
        if @kit_filling.present? and status
          @kit_filling.kit_copy.update_attribute("location_id", @loc.first.id)
          @kit_filling.destroy
          respond_to do |format|
            format.html { redirect_to kit_copies_path, notice: 'Kit Filling Canceled successfully.'}
            format.json { head :no_content }
          end
        else
          notice = get_revision_message params[:id], "Kitting::KitFilling"
          respond_to do |format|
            format.html { redirect_to kit_copies_path, alert: notice }
            format.json { head :no_content }
          end
        end
      end
    end

    # on clicking edit btn, it popsup with part-number and demand quantity to fill that cup on filling page
    def search_parts
      @kit_filling = Kitting::KitFilling.find_by_id(params[:kit_filling_id])
      if @kit_filling.present?
        if @kit_filling.kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
          cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id),:commit_status => true, :id => params[:cup_id])
        else
          cups = @kit_filling.kit_copy.kit.cups.where('commit_status = ? and id = ?', true,params[:cup_id])
        end
        @kit_filling = cups.map! do |cup|
          cup.try(:cup_parts).where('commit_status = ? and status = ? and cup_id = ?',true, 1, params[:cup_id]).map! do |cup_part|
            (cup_part.id.to_s+" "+ cup_part.try(:part).try(:part_number) +" "+cup_part.try(:demand_quantity)).split(" ") if cup_part.status
          end
        end
        render json: @kit_filling
      else
        render json: {"error" => true }
      end
    end

    # on clicking edit btn, it popup with part-number and demand quantity to fill that cup on kit filling edit page

    def edit_search_parts
      @kit_filling = Kitting::KitFilling.find_by_id(params[:kit_filling_id])
      status = @kit_filling.rbo_status == "Revoked" rescue false
      if @kit_filling.present? and status
        if @kit_filling.kit_copy.kit.kit_media_type.kit_type == "multi-media-type"
          cups = Kitting::Cup.where(:kit_id => Kitting::Kit.where(:parent_kit_id => @kit_filling.kit_copy.kit.id).where(:commit_status => true).map(&:id),:commit_status => true, :id => params[:cup_id])
        else
          cups = @kit_filling.kit_copy.kit.cups.where('commit_status = ? and id = ?', true,params[:cup_id])
        end
        @kit_filling = cups.map! do |cup|
          cup.try(:cup_parts).where('commit_status = ? and status = ?',true, 1).map! do |cup_part|
            (cup_part.id.to_s+" "+ cup_part.try(:part).try(:part_number) +" "+cup_part.try(:demand_quantity) +" "+ get_filled_quantity(cup_part.try(:id), params[:kit_filling_id])).split(" ") if cup_part.status
          end
        end
        render json: @kit_filling
      else
        render json: {"error" => true }
      end
    end

    # once the filling done on selecting queue for sending the kit it will check the open order for that kit

    def find_open_order
      @kit_filling = Kitting::KitFilling.find_by_id(params[:kit_filling_id]) # true or false
      @status = @kit_filling.rbo_status == "Revoked" rescue false
      if @kit_filling.present? and @status
        kit_number = @kit_filling.try(:kit_copy).try(:kit).try(:kit_number)
        kit_copy_number = @kit_filling.try(:kit_copy).try(:kit_version_number).split('-').last
        if ApplicationController.helpers.get_customer_list(current_customer.cust_no).first.prevent_kit_copy?
          @bailment_info = invoke_webservice method: "get", action: "bailmentInfo", query_string: { custNo: current_user,partNo:kit_number ,mailFlag:"N" }
          @bailment_status = @bailment_info["copyNums"].include?("COPY".concat(kit_copy_number))
        end
        @kit_open_order = invoke_webservice method: "get", action: "kitOpenOrder", query_string: {custNo: current_user, kitId: kit_number}
        render json: { "kit_order_no"=> @kit_open_order["orderNoList"], "kit_scan_code"=> @kit_open_order["scancodeList"], "errCode" => @kit_open_order["errCode"],"errMsg" => @kit_open_order["errMsg"], "bailment_flag" => @bailment_status  }
      else
        render json: { "error" => true }
      end
    end

    # while destroying the filling  kit or
    def reset_filled_kit
      @kit_filling_reset = Kitting::KitFilling.find_by_id(params[:data])
      if @kit_filling_reset.nil?
        render json: @kit_filling_reset
      else
        @kit_filling_reset.update_attribute(:flag, 0)
        location_id = Kitting::Location.find_by_name("Empty Queue").id
        @kit_filling_reset.kit_copy.update_attribute(:location_id, location_id)
        render json: @kit_filling_reset
      end
    end

    def get_cup_changes
      @kit_copy = KitCopy.where('id= ?', params[:id])
      kit_current_version = @kit_copy.first.kit.current_version
      @changed_kit_data = invoke_webservice method: "get", action: "kitDelta", query_string: {kitBomVersion: kit_current_version , kitNo: @kit_copy.first.kit.kit_number, kitCopyVersion: @kit_copy.first.version_status }
      changed_cups = []
      if @changed_kit_data.first["errCode"].present?
        render json: "Service Temporarily Down"
      else
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
        end
        render json: changed_cups.uniq

      end
    end

    private

    def find_location(location_id)
      @location = Kitting::Location.find(location_id)
      @location.name
    end

    # check filled quantity before sending kit copy to send to stock queue

    def check_filled_quantity(kit_filling)
      if Kitting::Location.find(params[:kit_filling][:location_id]).name != 'Send to Stock'
        return true
      else
        return kit_filling.kit_filling_details.map(&:filled_state).all? {|x| x == "F"}
      end
    end

    # check order exist or not defore sending to ship/invoice

    def check_order_for_ship(kit_filling,order_value)
      if Kitting::Location.find(params[:kit_filling][:location_id]).name == 'Ship/Invoice' && order_value.blank?
        return false
      else
        return true
      end
    end
  end
end