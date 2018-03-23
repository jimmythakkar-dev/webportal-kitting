require_dependency "kitting/application_controller"

module Kitting
  class CribPartRequestsController < ApplicationController
    before_filter :set_bin_center, :only => [:print,:new,:get_binloc,:index]
    def index
      @orders = Order.get_ad_hoc_orders
      order_details = Array.new
      if @orders.size > 0
        @orders.in_groups_of(5,false){|group|
          if params[:cancellation_date].present?
            start_date = Time.now
            end_date = (Time.now + params[:cancellation_date].to_i.days)
            if params[:cancellation_date].to_i.positive?
              group.each {|o| order_details << o.order_part_details.where("part_number LIKE ? and location_id != ? and created_at BETWEEN ? AND ?","%#{params["ag_part_number_search"]}%", Kitting::Location.find_by_name("Ship/Invoice").id, start_date, end_date)}
            else
              group.each {|o| order_details << o.order_part_details.where("part_number LIKE ? and location_id != ? and created_at BETWEEN ? AND ?","%#{params["ag_part_number_search"]}%", Kitting::Location.find_by_name("Ship/Invoice").id, end_date, start_date)}
            end
          else
            group.each {|o| order_details << o.order_part_details.where("part_number LIKE ? and location_id != ?","%#{params["ag_part_number_search"]}%", Kitting::Location.find_by_name("Ship/Invoice").id)}
          end
        }
        @order_part_details = order_details.flatten.paginate(params[:page], 25)
      end
    end
    # Displays New Crib part request screen
    def new
      if @dft_part_bin == "-"
        @error = "Please setup default crib part bin center to continue."
      else
        @crib_request = Order.new
        @work_orders = Kitting::Kit.where(:cust_no => current_user,:category => "AD HOC").map(&:kit_work_orders).flatten.map(&:work_order)
        @aircraftId = @work_orders.map(&:serial_number).uniq.sort
        @kit_part_nos = []
        @stations  = @work_orders.map(&:stage).uniq.sort
        @delivery_points = AgustaStation.where("station_type IN (?) and customer_number = ? ", "DELIVERY_POINT", "SYSTEM" ).pluck(:name)
      end
    end
    #  Creates Order and Order Part Details
    def create
      hash = {:order_status => "0",:due_date => Date.today + 5.days,:order_number => DateTime.now.strftime('%d %m %y %H %M %S').gsub(" ","") + SecureRandom.hex(3), :order_type => "CRIB", :customer_name => current_customer.cust_name,:customer_number => current_user,:created_by =>current_customer.user_name}
      params[:order].merge!(hash)
      @order = Order.new(params[:order])
      if @order.save
        if @order.order_part_details.count > 0
          flash[:success] = "Order Created Successfully with Order Number #{@order.order_number} and #{@order.order_part_details.count} Parts"
          redirect_to crib_part_requests_path
        else
          @order.destroy
          flash[:error] = "Can't Create Order without any parts."
          redirect_to new_crib_part_request_path
        end
      else
        flash[:error] = "Order Not Saved Errors:\r \n #{@order.errors.full_messages.join(",")}"
        redirect_to new_crib_part_request_path
      end
    end
    # Manipulates through work order and gets KIT PN
    def get_kit_part_numbers
      @kit_part_nos = Kitting::WorkOrder.joins(:kits).where("serial_number = ? and kits.cust_no = ?", params[:aircraft_id],current_user).map(&:kits).flatten
      render :json => { :kit_part_nos => @kit_part_nos.map { |kpn| [kpn.id,kpn.customer_kit_part_number]}.uniq_by {|kit| kit[1]} }
    end
    # Validates Bin Location present or not
    def get_binloc
      @crib_pick_details = invoke_webservice method: 'get', action: 'getPartBinInfo', query_string: { custNo: current_user, binCenter: @dft_part_bin, partNumbers: params[:part_no] }
      if @crib_pick_details && @crib_pick_details["errMsg"] == ""
        result = {:status => true , :list => @crib_pick_details["binLocation"].reject {|part| part.blank? || part == "-" } }
      else
        result = {:status => false }
      end
      render :json => result.to_json
    end
    # Populates kit details after selecting aircraft id and kit PN
    def populate_kit_details
      if request.xhr?
        @kit_parts_details = Kitting::KitWorkOrder.find_by_kit_id(params[:kit_part_no]).kit.cups.where(:status => true).map(&:cup_parts).flatten.select { |cp| cp.status == true} rescue []
        @crib_request = Order.new
      end
    end
    # Validates Part Number while addding extra parts
    def validate_part_no
      @part = params[:partNo].strip
      @phillyKit = params[:phillyKit]
      @index= @phillyKit.to_i + 1
      @uom = params[:uom].strip
      @contract_details = invoke_webservice method: 'get', class: 'custInv/',action:'vldPartNoUM', query_string: {custNo: current_user, partNo: @part , UM: @uom }
    end

    def history
      @orders = Order.where("order_type = ? or order_type = ?", "SOS", "CRIB")
      order_details = Array.new
      if @orders.size > 0
        @orders.in_groups_of(5,false){|group|
          group.each {|o| order_details << o.order_part_details.where("part_number LIKE ?","%#{params["ag_part_number_search"]}%")}
        }
        @order_part_details = order_details.flatten.paginate(params[:page], 100)
      end
    end
    # Pick ticket Print
    def print
      @order_part_details = OrderPartDetail.find_all_by_id(params["print"])
      if @order_part_details.present? && params[:commit] == "Print Pick Sheet"
        selected_crib_parts = @order_part_details.map(&:part_number).reject(&:blank?)
        @dft_part_bin = params["crib_bin_center"] if params["crib_bin_center"].present?
        if @dft_part_bin == "-"
          render :text => "<script type=\"text/javascript\">if (confirm('Please setup/select Bin Center to print pick sheet')){ window.close(); } </script>"
        else
          @crib_pick_details = invoke_webservice method: 'get', action: 'getPartBinInfo', query_string: { custNo: current_user, binCenter: @dft_part_bin, partNumbers: selected_crib_parts.join(',') }
          if @crib_pick_details
            if @crib_pick_details["errMsg"].present?
              render :text => "<script type=\"text/javascript\">if (confirm('An error has Occured :#{@crib_pick_details["errMsg"]}')){ window.close(); } </script>"
            else
              @crib_bin_locations = @crib_pick_details["binLocation"]
              if @crib_bin_locations.present?
                no_bin_indices = @crib_bin_locations.each_index.select{|i| @crib_bin_locations[i] == '-'}
                part_bin_zip = @crib_pick_details["partNumbers"].zip(@crib_bin_locations)
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
                          @crib_bin_locations[no_bin_index] = power_bin_locations[power_index] if power_bin_locations[power_index].present?
                        end
                      end
                    end
                  end
                end
              end
              @combine_crib_parts_arr = []
              picking_loc = Kitting::Location.find_by_name("Picking Queue")
              @order_part_details.each_with_index do |part_detail,index|
                part = part_detail.part_number
                qty = part_detail.quantity
                uom = part_detail.uom
                bin_location = @crib_bin_locations[index] rescue "-"
                details_hash = {part: part, qty: qty, uom: uom, bin: bin_location}
                @combine_crib_parts_arr << details_hash
                part_detail.update_attributes(:bin_location => bin_location, :location_id => picking_loc.id)
              end
              @combine_crib_parts_arr = @combine_crib_parts_arr.sort_by { |all_parts| all_parts[:bin] || ""}
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
        @order_parts = OrderPartDetail.find_all_by_id(params["print_label"])
        if @order_parts.present? && params[:commit] == "Print Inner Labels"
          respond_to do |format|
            format.html do
              render :pdf => "print.html.erb",
                     :page_height => '2.5in',
                     :page_width => '4in',
                     :margin => {:top => 0,:bottom => 0,:left => 0,:right => 0 }
            end
          end
        end
      end
    end

    def ship_crib_part_list
      @orders = Order.get_ad_hoc_orders
      order_details = Array.new
      if @orders.size > 0
        @orders.in_groups_of(5,false){|group|
          group.each {|o| order_details << o.order_part_details.where("part_number LIKE ? and location_id = ?","%#{params["ag_part_number_search"]}%", Kitting::Location.find_by_name("Picking Queue").id)}
        }
        @order_part_details = order_details.flatten.paginate(params[:page], 100)
      end
    end

    def ship_crib_part
      @order_part_details = OrderPartDetail.where("id in (?)", params["print"])
      order_id = Array.new
      if @order_part_details
        @order_part_details.each do |part|
          order_id << part.order.id unless order_id.include? (part.order.id)
          part.update_attributes(filled_state: "F", location_id: Kitting::Location.find_by_name("Ship/Invoice").id, shipment_date_time: DateTime.now)
        end
      end
      @orders = Order.find_all_by_id(order_id)
      @orders.each do |order|
        filled_state = order.order_part_details.map(&:filled_state)
        if filled_state.include? ("P") or filled_state.include? ("E")
          order.update_attributes(order_status: "2")
        else
          order.update_attributes(order_status: "1")
        end
      end
      flash[:notice] = "Parts shipped successfully"
      redirect_to ship_crib_part_list_crib_part_requests_path
    end
    private
    def set_bin_center
      cust_config = Kitting::CustomerConfigurations.find_by_cust_no(current_user)
      if cust_config.present?
        @dft_part_bin = cust_config.default_crib_part_bin_center.present? ? cust_config.default_crib_part_bin_center : "-"
      else
        @dft_part_bin = "-"
      end
    end
  end
end
