require_dependency "kitting/application_controller"

module Kitting
  class KitDeliveryController < ApplicationController
    # List Index page for user to enter delivery details.
    def index

    end
    # Process Deliveries
    def process_deliveries
      @result_set = Array.new
      @delivery_points = AgustaStation.where(:customer_number => "SYSTEM",:station_type => "DELIVERY_POINT").pluck("agusta_stations.name").map(&:upcase)
      params[:scanned_list].split(/\r\n/).each do |list|
        list_arr = list.split(",")
        valid_date = DateTime.strptime(list_arr[2].scan(/.{1,2}/).join(" "),"%m %d %y %H %M").is_a?(DateTime) rescue false
        delivery_point_entered = list_arr[0].strip.slice(1..-1).present? ? list_arr[0].strip.slice(1..-1).upcase : list_arr[0].strip.slice(1..-1) rescue false
        if list_arr.count == 3 && delivery_point_entered && @delivery_points.include?(delivery_point_entered) && valid_date
          #  CONDITION TO CHECK DELIVERY ID OR PACK ID
          id_type = list_arr[1].split("-").count == 1 ? "Delivery" : "Pack"
          if id_type == "Delivery"
            @kit_order = Kitting::KitOrderFulfillment.find_by_kit_filling_id(list_arr[1])
          else
            @kit_order = OrderPartDetail.find_by_pack_id(list_arr[1])
          end
          if @kit_order && @kit_order.delivery_date.nil?
            if @kit_order.update_attributes(:delivered => true, :delivery_date => DateTime.strptime(list_arr[2].scan(/.{1,2}/).join(" "),"%m %d %y %H %M"),:delivery_point => list_arr[0].strip.slice(1..-1))
              @result_set.push([1,list])
            else
              @result_set.push([7,list])
            end
          else
            @kit_order.present? ? @result_set.push([5,list,@kit_order.delivery_date.in_time_zone("UTC")]) : @result_set.push([2,list])
          end
        else
          list_arr.count == 3 ? valid_date ? @delivery_points.include?(list_arr[0].strip.slice(1..-1)) ?  "" : @result_set.push([3,list]) : @result_set.push([4,list]) : @result_set.push([6,list])
          # valid_date ? @delivery_points.include?(list_arr[0].strip.slice(1..-1)) ? list_arr.count == 3 ? "" : @result_set.push([6,list]) : @result_set.push([3,list]) : @result_set.push([4,list])
        end
      end
      render 'index'
    end
  end
end