class OrderRefill

  class << self
    # Preparing select box values for date range
    # Including Today, 2 Days, 3 Days etc
    # Default to 2 Months
    ##
    def get_select_values
      select_tag_values = [[I18n.translate("today",:scope => "open_orders.index"),"0"], ["2 #{I18n.translate("days",:scope => "open_orders.index")}","2"], ["3 #{I18n.translate("days",:scope => "open_orders.index")}","3"],
                           ["5 #{I18n.translate("days",:scope => "open_orders.index")}","5"], ["1 #{I18n.translate("week",:scope => "open_orders.index")}","7"], ["2 #{I18n.translate("weeks",:scope => "open_orders.index")}","14"],
                           ["1 #{I18n.translate("month",:scope => "open_orders.index")}","30"], ["2 #{I18n.translate("months",:scope => "open_orders.index")}","60"], ["3 #{I18n.translate("months",:scope => "open_orders.index")}","90"],
                           ["4 #{I18n.translate("months",:scope => "open_orders.index")}","120"], ["5 #{I18n.translate("months",:scope => "open_orders.index")}","150"],
                           ["6 #{I18n.translate("months",:scope => "open_orders.index")}","180"], ["8 #{I18n.translate("months",:scope => "open_orders.index")}","240"], [I18n.translate("year",:scope => "open_orders.index"),"365"]]
      select_tag_values
    end

    ##
    # Preparing select box values for search by values
    # Including Part Number, PO Number, All Refill Orders
    ##
    def get_search_values
      search_by_values = [[I18n.translate("part_number",:scope => "open_orders.index"),"pn"],[I18n.translate("po_number",:scope => "open_orders.index"),"po"],
                          [I18n.translate("all_refill_order",:scope => "order_refill.index"),"all"]]

      search_by_values
    end
    # SORT & FILTER ARRAY BASED FROM CFM CODE
    def sort_record(response_refill_order)
      list =response_refill_order.pick("transferNo" , "createScan" , "shipDate" , "actualDate" , "recDate" , "status" , "poNo" , "custPN" , "ordQty" , "shipQty" , "controlNo" , "scancode" , "binCenter" , "binLoc" , "trackingNo")
      response_list = {}
      response_list.compare_by_identity
      list["transferNo"].each_with_index do |transferNo,index|
        response_list[transferNo] = {
            :createScan => list["createScan"][index],
            :shipDate => list["shipDate"][index],
            :actualDate => list["actualDate"][index],
            :recDate => list["recDate"][index],
            :status => list["status"][index],
            :poNo => list["poNo"][index],
            :custPN => list["custPN"][index],
            :ordQty => list["ordQty"][index],
            :shipQty => list["shipQty"][index],
            :controlNo => list["controlNo"][index],
            :scancode => list["scancode"][index],
            :binCenter => list["binCenter"][index],
            :binLoc => list["binLoc"][index],
            :trackingNo => list["trackingNo"][index]
        }
      end
      # COMMENTING FILTER FOR RECDATE AS PER ANTONIO'S FEEDBACK.
       response_list.delete_if {|_,v| v[:recDate] == "Deleted" || v[:recDate] == "Bad fm Stk" || v[:recDate] == "Not Recvd" || v[:recDate] == "Cancelled" || v[:recDate] == "##" }
      # response_list = Hash[response_list.sort.reverse]
      begin
        sorted_array = response_list.sort do |x,y|
          x <=> y || 0
        end.reverse
        response_hash = {}
        response_hash.compare_by_identity
        sorted_array.each_with_index { |value,key|
          response_hash[value[0]]= value[1]
        }
      rescue
        response_hash = {}
      end
      return response_hash
    end
  end
end
