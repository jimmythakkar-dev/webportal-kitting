module Kitting
  module CribPartRequestsHelper
    # def split_in_groups(orders, page)
    #   part_arr = []
    #   orders.each do |order|
    #     order.order_part_details.each do |part|
    #       part_arr << part
    #     end
    #   end
    #   return part_arr.in_groups_of(5, false)[page.to_i - 1 || 0], part_arr.in_groups_of(5, false).size
    # end
    def get_part_status(part)
      if part.order.auto_cancelled
        if part.cancellation_date
          status = "Auto Cancelled at #{part.order.cancellation_date.strftime("%m/%d/%Y")}"
        elsif part.location.try(:name) == "Ship/Invoice"
          status = "Shipped at #{part.shipment_date_time.strftime("%m/%d/%Y")}"
        end
      else
        case part.location.try(:name)
          when "NEW KIT QUEUE"
            status = "In #{part.location.try(:name)}"
          when "Picking Queue"
            status = "In #{part.location.try(:name)}"
          when "Ship/Invoice"
            status = "Shipped at #{part.shipment_date_time.strftime("%m/%d/%Y")}"
          else
            status = "-"
        end
      end
    end

    def get_crib_bin(current_user)
      crib_bincenters = invoke_webservice method: 'get', class: 'custInv/',action:'binCenters',query_string: {custNo: current_user }
      if crib_bincenters && crib_bincenters["errMsg"].blank?
        if crib_bincenters["binCenterList"].include?(@dft_part_bin)
          crib_bin_list = crib_bincenters["binCenterList"]
        else
          crib_bin_list = crib_bincenters["binCenterList"] << "-"
        end
      else
        "-"
      end
    end
  end
end
