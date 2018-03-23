require_dependency "kitting/application_controller"

module Kitting
  class KitWorkOrdersController < ApplicationController
    include Kitting::KitWorkOrdersHelper
    before_filter :set_part_bin_center, :only => [:print]
    def index
      if can?(:>=, "4") && adhoc_kit_access?
        @days_format = get_date_range
        @location = Kitting::Location.find_by_name("Ship/Invoice")
        params[:ag_kit_number_search] = params[:ag_kit_number_search].try(:strip)
        params[:ag_kit_wo_search] = params[:ag_kit_wo_search].try(:strip)
        params[:start_date] = params[:start_date].try(:strip)
        if params[:location].present?
          @kit_work_orders = Kitting::KitWorkOrder.where('created_by IN (?) and location_id = ? ',current_company,@location.try(:id))
          @block_pick = true
        elsif params[:start_date].present?
          start_date = Time.now
          end_date = (Time.now + params[:start_date].to_i.days)
          if params[:start_date].to_i.positive?
            if params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
              kit_ids = get_kit_ids
              work_orders = get_work_order_ids
              @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and work_order_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ? ', kit_ids, work_orders , start_date , end_date,current_company,@location.try(:id))
            elsif params[:ag_kit_number_search].present? && !params[:ag_kit_wo_search].present?
              kit_ids = get_kit_ids
              kit_ids.in_groups_of(500) { |group|
                @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?', group,start_date ,end_date,current_company,@location.try(:id))
              }
            elsif !params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
              work_orders = get_work_order_ids
              work_orders.in_groups_of(500) { |group|
                @kit_work_orders = Kitting::KitWorkOrder.where('work_order_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?', group,start_date ,end_date,current_company,@location.try(:id))
              }
            else
              @kit_work_orders = Kitting::KitWorkOrder.where('due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?',start_date ,end_date, current_company,@location.try(:id))
            end
          else
            if params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
              kit_ids = get_kit_ids
              work_orders = get_work_order_ids
              @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and work_order_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?', kit_ids, work_orders , end_date, start_date,current_company,@location.try(:id))
            elsif params[:ag_kit_number_search].present? && !params[:ag_kit_wo_search].present?
              kit_ids = get_kit_ids
              kit_ids.in_groups_of(500) { |group|
                @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?', group,end_date,start_date,current_company,@location.try(:id))
              }
            elsif !params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
              work_orders = get_work_order_ids
              work_orders.in_groups_of(500) { |group|
                @kit_work_orders = Kitting::KitWorkOrder.where('work_order_id in (?) and due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?', group,end_date,start_date,current_company,@location.try(:id))
              }
            else
              @kit_work_orders = Kitting::KitWorkOrder.where('due_date BETWEEN ? AND ? AND created_by IN (?) and location_id != ?',end_date,start_date, current_company,@location.try(:id))
            end
          end
        else
          if params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
            kit_ids = get_kit_ids
            work_orders = get_work_order_ids
            @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and work_order_id in (?) and created_by IN (?) and location_id != ?', kit_ids, work_orders , current_company,@location.try(:id))
          elsif params[:ag_kit_number_search].present? && !params[:ag_kit_wo_search].present?
            kit_ids = get_kit_ids
            kit_ids.in_groups_of(500) { |group|
              @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and created_by IN (?) and location_id != ?', group,current_company,@location.try(:id))
            }
          elsif !params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
            work_orders = get_work_order_ids
            work_orders.in_groups_of(500) { |group|
              @kit_work_orders = Kitting::KitWorkOrder.where('work_order_id in (?) and created_by IN (?) and location_id != ?', group,current_company,@location.try(:id))
            }
          else
            @kit_work_orders = Kitting::KitWorkOrder.where('created_by IN (?) and location_id != ?', current_company,@location.try(:id))
          end
        end
        if @kit_work_orders
          @kit_work_orders = @kit_work_orders.flatten.paginate(params[:page], 25)
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
    def new
      if can?(:>=, "5") && adhoc_kit_access?
        params[:page] = params[:page].nil? ? 1 : params[:page]
        @kit_upload = Kitting::KitBomBulkOperation.new(:operation_type => "AD HOC KIT")
        @kit_uploads = Kitting::KitBomBulkOperation.where("operation_type = ? and customer_id IN (?)","AD HOC KIT",current_company).paginate(:page => params[:page], :per_page => 100).order('created_at desc')
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @kit_uploads }
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end
    def create

    end
    def show
      if can?(:>=, "4") && adhoc_kit_access?
        @kit_work_order = Kitting::KitWorkOrder.find(params[:id])
        @kit = @kit_work_order.kit
        @versions = Version.where("(item_type = 'Kitting::KitWorkOrder' AND item_id = #{@kit_work_order.id})")
      else
        redirect_to main_app.unauthorized_url
      end
    end
    def work_order_fillings
      @location = Kitting::Location.where("customer_number = ? OR customer_number IS NULL",session[:customer_number])
      params[:ag_kit_number_search] = params[:ag_kit_number_search].try(:strip)
      params[:ag_kit_wo_search] = params[:ag_kit_wo_search].try(:strip)
      params[:kit_queue] = params[:kit_queue]

      if params[:kit_queue].present?
        if params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
          kit_ids = get_kit_ids
          work_orders = get_work_order_ids
          @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and work_order_id in (?) and location_id = ? and created_by IN (?)', kit_ids, work_orders ,params[:kit_queue], current_company)
        elsif params[:ag_kit_number_search].present? && !params[:ag_kit_wo_search].present?
          kit_ids = get_kit_ids
          kit_ids.in_groups_of(500) { |group|
            @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and location_id = ? and created_by IN (?)', group, params[:kit_queue],current_company)
          }
        elsif !params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
          work_orders = get_work_order_ids
          work_orders.in_groups_of(500) { |group|
            @kit_work_orders = Kitting::KitWorkOrder.where('work_order_id in (?) and location_id = ? and created_by IN (?)', group, params[:kit_queue],current_company)
          }
        else
          @kit_work_orders = Kitting::KitWorkOrder.where('location_id = ? and created_by IN (?)',params[:kit_queue], current_company)
        end
      else
        if params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
          kit_ids = get_kit_ids
          work_orders = get_work_order_ids
          @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and work_order_id in (?) and created_by IN (?)', kit_ids, work_orders ,current_company)
        elsif params[:ag_kit_number_search].present? && !params[:ag_kit_wo_search].present?
          kit_ids = get_kit_ids
          kit_ids.in_groups_of(500) { |group|
            @kit_work_orders = Kitting::KitWorkOrder.where('kit_id in (?) and created_by IN (?)', group, current_company)
          }
        elsif !params[:ag_kit_number_search].present? && params[:ag_kit_wo_search].present?
          work_orders = get_work_order_ids
          work_orders.in_groups_of(500) { |group|
            @kit_work_orders = Kitting::KitWorkOrder.where('work_order_id in (?) and created_by IN (?)', group, current_company)
          }
        else
          @kit_work_orders = Kitting::KitWorkOrder.where('created_by IN (?)',current_company)
        end
      end
      if @kit_work_orders
        kit_work_orders_ids = @kit_work_orders.map(&:id)
        @work_order_fillings = Kitting::KitFilling.where("flag = ? AND customer_id in (?) and kit_work_order_id IN (?)",true,current_company, kit_work_orders_ids).paginate(:page => params[:page], :per_page => 25).order('updated_at desc')
      end
    end

    def edit
      @kit_work_order = Kitting::KitWorkOrder.find_by_id(params[:id])
      @all_work_order = Kitting::KitWorkOrder.where('work_order_id = ? ', @kit_work_order.work_order_id)
    end

    def update_due_date
      @kit_work_order = Kitting::KitWorkOrder.find_by_id(params[:id])
      due_date = Date.strptime(params[:due_date],"%m/%d/%Y")
      if params["update"] == "all"
        @all_work_order = Kitting::KitWorkOrder.where('work_order_id = ? ', @kit_work_order.work_order_id)
        @all_work_order.each do |work_order|
          work_order.update_attribute("due_date", due_date)
        end
      else
        @kit_work_order.update_attribute("due_date", due_date)
      end
      redirect_to kit_work_order_path(@kit_work_order)
    end

    def print
      if can?(:>=, "4") && adhoc_kit_access?
        if params[:commit] == 'Print Outer Labels'
          @kit_work_orders = Kitting::KitWorkOrder.find_all_by_id(params["print_label"])
          respond_to do |format|
            format.html do
              render :pdf => "print_label.html.erb",
                     :page_height => '2in',
                     :page_width => '3in',
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        elsif params[:commit] == 'Print Inner Labels'
          @kit_work_orders = Kitting::KitWorkOrder.find_all_by_id(params["print_label"])
          if @kit_work_orders
            kit_work_order_hash = Hash.new
            @kit_work_orders.each_with_index do |kwo, k|
              kit_work_order_hash[kwo.id] = Hash.new
              kit_filling_id = Kitting::KitFilling.find_by_kit_work_order_id(kwo.id).id
              kwo.kit.cups.where(:commit_status => true, :status => true ).each_with_index do |cup, c|
                c = (c + 1)
                if cup.cup_parts.where(:commit_status => true, :status => true ).size > 0
                  kit_work_order_hash[kwo.id][c] = Hash.new
                  kit_work_order_hash[kwo.id][c]["detail_part"] = cup.cup_parts.first.part.part_number
                  kit_work_order_hash[kwo.id][c]["qty"] = cup.cup_parts.first.demand_quantity
                  kit_work_order_hash[kwo.id][c]["bin_center"] = kwo.kit.bincenter
                  kit_work_order_hash[kwo.id][c]["bin_id"] = Kitting::KitFillingDetail.find_by_kit_filling_id_and_cup_part_id(kit_filling_id, cup.cup_parts.first.id).bin_location
                  kit_work_order_hash[kwo.id][c]["work_order"] = kwo.work_order.order_number
                  kit_work_order_hash[kwo.id][c]["job_card_no"] = kwo.kit.customer_kit_part_number
                  kit_work_order_hash[kwo.id][c]["pack_id"] = Kitting::KitFillingDetail.find_by_kit_filling_id_and_cup_part_id(kit_filling_id, cup.cup_parts.first.id).pack_id
                  kit_work_order_hash[kwo.id][c]["aircraft"] = kwo.work_order.serial_number
                end
              end
            end
          end
          kit_work_order_arr = Array.new
          kit_work_order_hash.each{ |k,v| v.each{ |k1,v1| kit_work_order_arr << v1 }}
          if params[:print_sort_by] == 'Bin Location'
            @kit_work_orders = kit_work_order_arr.sort_by{|all| all["bin_id"] || ""}
          elsif params[:print_sort_by] == 'Part Number'
            @kit_work_orders = kit_work_order_arr.sort_by{|all| all["detail_part"] || ""}
          else
            @kit_work_orders = kit_work_order_arr
          end
          respond_to do |format|
            format.html do
              render :pdf => "print_label.html.erb",
                     :page_height => '2.5in',
                     :page_width => '4in',
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        elsif params[:commit] == 'BOM Label'
          @kit_work_orders = Kitting::KitWorkOrder.find_by_id(params["print_label"])
          @kit = Kitting::Kit.find_by_id(params[:kit_id])
          respond_to do |format|
            format.html do
              render :pdf => "print_label.html.erb",
                     :page_height => '2.5in',
                     :page_width => '4in',
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        else
          if params[:multi_pick_ticket].present?
            @kit_work_orders = Kitting::KitWorkOrder.where('id in (?)',params[:multi_pick_ticket])
            kit_ids =  @kit_work_orders.map(&:kit_id)
            all_parts = Array.new; part_kit_number=Array.new;
            @kit_work_orders.each do |kwo|
              cup_parts = kwo.kit.cup_parts.where(:status => true)
              cup_parts.each do |cup_part|
                all_parts << cup_part.part.part_number.upcase
                part_kit_number << cup_part.cup.kit.customer_kit_part_number
              end
            end
            if @dft_part_bin == "-"
              render :text => "<script type=\"text/javascript\">if (confirm('Please Setup Part Bin Center to print pick sheet')){ window.close(); } </script>"
            else
              all_parts.reject!(&:blank?)
              @pick_ticket_print_details = invoke_webservice method: 'get', action: 'getPartBinInfo',
                                                             query_string: { custNo: current_user, binCenter: @dft_part_bin, partNumbers: all_parts.join(',') }

              if @pick_ticket_print_details
                if @pick_ticket_print_details["errMsg"].present?
                  render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@pick_ticket_print_details["errMsg"]}')){ window.close(); } </script>"
                else
                  @bin_locations = @pick_ticket_print_details["binLocation"]
                  if @bin_locations.present?
                    no_bin_indices = @bin_locations.each_index.select{|i| @bin_locations[i] == '-'}
                    part_bin_zip = @pick_ticket_print_details["partNumbers"].zip(@bin_locations)
                    pow_tech_check_parts = part_bin_zip.select { |part| part[1] == "-"}.flatten.reject{|special| special == "-"}
                    unless pow_tech_check_parts.blank?
                      power_bin_center =  Kitting::CustomerConfigurations.find_by_cust_no("027197").default_part_bin_center
                      if power_bin_center.present?
                        power_tech_rbo_call = invoke_webservice method: 'get', action: 'getPartBinInfo',
                                                                query_string: { custNo: "027197", binCenter: power_bin_center, partNumbers: pow_tech_check_parts.join(',') }
                        if power_tech_rbo_call && power_tech_rbo_call["errMsg"].blank?
                          power_bin_locations = power_tech_rbo_call["binLocation"]
                          if power_bin_locations.present? && (power_bin_locations.length == no_bin_indices.length)
                            no_bin_indices.each_with_index do |no_bin_index, power_index|
                              @bin_locations[no_bin_index] = power_bin_locations[power_index] if power_bin_locations[power_index].present?
                            end
                          end
                        end
                      end
                    end
                  end
                  bin_index = 0
                  pick_index = 0
                  @combine_parts_arr = []
                  @kit_work_orders.each do |kwo|
                    cup_parts = kwo.kit.cup_parts.where(:status => true)
                    cup_parts.each do |cup_part|
                      pick_part_hash = {cup_number: cup_part.cup.cup_number, part_number: cup_part.part.part_number, kit_no: kwo.kit.customer_kit_part_number, work_order: kwo.work_order.order_number, req_qty: cup_part.demand_quantity, bin_loc: @bin_locations[pick_index], uom: cup_part.uom }
                      @combine_parts_arr << pick_part_hash
                      pick_index = pick_index + 1
                    end
                  end
                  if params[:pick_style] == 'Combine All'
                    if params[:pick_sort_by] == 'Bin Loc'
                      @combine_parts_arr = @combine_parts_arr.sort_by { |all_parts| all_parts[:bin_loc] || ""}
                    elsif params[:pick_sort_by] == 'Part Number'
                      @combine_parts_arr = @combine_parts_arr.sort_by { |all_parts| all_parts[:part_number] }
                    else
                      @combine_parts_arr = @combine_parts_arr.sort_by { |all_parts| all_parts[:cup_number] }
                    end
                  end
                  picking_loc = Kitting::Location.find_by_name("Picking Queue")
                  @kit_work_orders.each do |kit_work_order|
                    check_wo = chk_kwo_present(kit_work_order.id)
                    unless check_wo
                      kf_hash = {kit_work_order_id: kit_work_order.id, flag: 1, created_by: current_user, location_id: picking_loc.id, filled_state: 1}
                      filling_create = current_customer.kit_fillings.create(kf_hash)
                      all_cup_parts = filling_create.kit_work_order.kit.cup_parts
                      all_cup_parts.map do |cup_part|
                        kfd_hash = { kit_filling_id: filling_create.id, cup_part_id: cup_part.id,filled_quantity: cup_part.demand_quantity, filled_state: 'F', bin_location: @bin_locations[bin_index] }
                        kit_filling_details = Kitting::KitFillingDetail.create(kfd_hash)
                        if kit_filling_details.bin_location.blank? || kit_filling_details.bin_location == "-"
                          if cup_part.demand_quantity == "WL" || cup_part.demand_quantity == "wl"
                            filled_qty = "E"
                          else
                            filled_qty = 0
                          end
                          kit_filling_details.update_attributes(:filled_quantity => filled_qty, :filled_state => 'E' )
                          filling_create.update_attribute('filled_state',2)
                        end
                        filling_histories_details = {:kit_number=> kit_work_order.kit.customer_kit_part_number,
                                                     :kit_work_order_id => kit_work_order.id,
                                                     :customer_number=>current_user,
                                                     :cup_no=>cup_part.try(:cup).try(:cup_number),
                                                     :part_number=>cup_part.try(:part).try(:part_number),
                                                     :demand_qty=>cup_part.demand_quantity,
                                                     :filled_qty=>kit_filling_details.filled_quantity,
                                                     :filling_date=>kit_filling_details.created_at,
                                                     :created_by=>filling_create.try(:customer).try(:user_name),
                                                     :kit_filling_id=>filling_create.id,
                                                     :cup_part_id=>cup_part.id,
                                                     :cup_part_status=>cup_part.status,
                                                     :cup_part_commit_status=>cup_part.commit_status
                        }
                        kit_filling_histories_report = Kitting::KitFillingHistoryReport.create(filling_histories_details)
                        bin_index = bin_index + 1
                      end
                      kit_work_order.update_attribute('location_id',picking_loc.id)
                    end
                  end
                  respond_to do |format|
                    format.html do
                      render :pdf => "print.html.erb",
                             :header => { :right => '[page] of [topage]',
                                          :line => true},
                             :footer => { :line => true},
                             :margin => {:top =>9, :bottom => 22, :left => 12, :right => 12 }
                    end
                  end
                end
              else
                render :text => "<script type=\"text/javascript\">if (confirm('Service temporary unavailable')){ window.close(); } </script>"
              end
            end
          else
            render :text => "<script type=\"text/javascript\">if (confirm('There is no Kit for print pick ticket.')){ window.close(); } </script>"
          end
        end
      else
        redirect_to main_app.unauthorized_url
      end
    end

    def part_receiving
    end

    def receive_parts
      split_params = params["part_received"].split("\r\n")
      @parts_received = Array.new; @kits_received = Array.new; @part_not_found =Array.new; @part_not_shipped = Array.new; @already_received = Array.new; @all_errors = Array.new
      if split_params
        split_params.each do |received|
          received = received.gsub(/\s+/, "").strip
          unless received.blank?
            #check for pack id or delivery id
            if received.include? "-"
              #check for CRIB PART or NOT
              if received.split("-").first == "CP"
                @order_part_detail = OrderPartDetail.find_by_pack_id(received)
                if @order_part_detail.present?
                  if !@order_part_detail.received_flag
                    if @order_part_detail.location.name == "Ship/Invoice" && !@order_part_detail.cancellation_date
                      @order_part_detail.update_attributes(received_flag: true)
                      return_report_entry = ReturnedPartDetail.returned_part_entry(@order_part_detail.id, 'Desk Request', current_user, current_customer.user_name)
                      @parts_received <<  received + " : " + @order_part_detail.part_number
                    else
                      @part_not_shipped << received + " : " + @order_part_detail.part_number
                    end
                  else
                    @already_received << received + " : " + @order_part_detail.part_number
                  end
                else
                  @part_not_found << received
                end
              else
                @kit_filling_details = Kitting::KitFillingDetail.find_by_pack_id(received)
                if @kit_filling_details.present?
                  if !@kit_filling_details.receive_flag
                    if @kit_filling_details.kit_filling.kit_work_order_id && !@kit_filling_details.kit_filling.flag && @kit_filling_details.kit_filling.rbo_status != "Revoked"
                      @kit_filling_details.update_attributes(receive_flag: true, receive_type: "part")
                      return_report_entry = ReturnedPartDetail.returned_part_entry(@kit_filling_details.id, 'Kitting Request', current_user, current_customer.user_name)
                      @parts_received <<  received + " : " + @kit_filling_details.cup_part.part.part_number
                    else
                      @part_not_shipped << received + " : " + @kit_filling_details.cup_part.part.part_number
                    end
                  else
                    @already_received << received + " : " + @kit_filling_details.cup_part.part.part_number
                  end
                else
                  @part_not_found << received
                end
              end
            else
              @kit_filling_details = Kitting::KitFillingDetail.where("kit_filling_id = ?",received.to_i)
              if @kit_filling_details.present?
                @kit_filling_details.each do |filling_details|
                  if filling_details.present?
                    if !filling_details.receive_flag
                      if filling_details.kit_filling.kit_work_order_id && !filling_details.kit_filling.flag && filling_details.kit_filling.rbo_status != "Revoked"
                        filling_details.update_attributes(receive_flag: true, receive_type: "kit")
                        return_report_entry = ReturnedPartDetail.returned_part_entry(filling_details.id, 'Kitting Request', current_user, current_customer.user_name)
                        @kits_received << received + " : " + filling_details.kit_filling.kit_work_order.kit.customer_kit_part_number
                      else
                        if filling_details.kit_filling.kit_work_order_id
                          @part_not_shipped << received + " : " + filling_details.kit_filling.kit_work_order.kit.customer_kit_part_number
                        else
                          @part_not_shipped << received + " : " + filling_details.kit_filling.kit_copy.kit.kit_number
                        end
                      end
                    else
                      if filling_details.kit_filling.kit_work_order_id
                        @already_received << received + " : " + filling_details.kit_filling.kit_work_order.kit.customer_kit_part_number
                      else
                        @already_received << received + " : " + filling_details.kit_filling.kit_copy.kit.kit_number
                      end
                    end
                  else
                    @part_not_found << received
                  end
                end
              else
                @part_not_found << received
              end
            end
          end
        end
      end
      @all_errors << @part_not_found << @already_received << @part_not_shipped
      @all_errors = @all_errors.flatten
      render '/kitting/kit_work_orders/part_receiving'
    end

    private

    def get_kit_ids
      Kitting::Kit.where('kit_number LIKE ? and category = ? ',"%#{params[:ag_kit_number_search]}%",'AD HOC').map(&:id)
    end
    def get_work_order_ids
      Kitting::WorkOrder.where('order_number LIKE ? AND created_by IN (?)', "%#{params[:ag_kit_wo_search]}%", current_company).map(&:id)
    end

    def set_part_bin_center
      cust_config = Kitting::CustomerConfigurations.find_by_cust_no(current_user)
      if cust_config.present?
        @dft_part_bin = cust_config.default_part_bin_center.present? ? cust_config.default_part_bin_center : "-"
      else
        @dft_part_bin = "-"
      end
    end
  end
end