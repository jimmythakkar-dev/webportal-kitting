module Kitting
  module KitWorkOrdersHelper
      def chk_kwo_present kwo
        # check_wo = Kitting::KitFilling.find_by_kit_work_order_id_and_flag_and_rbo_status(kwo,true,"Revoked")
        check_wo = Kitting::KitFilling.find_by_kit_work_order_id(kwo)
        if check_wo
          true
        else
          false
        end
      end
      def get_comment filling_details
        demand_quantity = filling_details.cup_part.demand_quantity.to_f
        filled_quantity = filling_details.filled_quantity.to_f
        if demand_quantity > filled_quantity
          "Short"
        else
          "-"
        end
      end
  end
end