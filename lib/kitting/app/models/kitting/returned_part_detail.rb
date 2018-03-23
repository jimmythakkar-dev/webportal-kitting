module Kitting
  class ReturnedPartDetail < ActiveRecord::Base
    self.table_name = 'returned_part_details'
    attr_accessible :date_completed, :job_card_description, :job_card_number, :part_number,
                    :quantity, :request_type, :requestor, :serial_number, :stage, :work_order, :cust_no

    def self.returned_part_entry(returned_id, request_type,curr_user,user_name)
      if request_type == 'Kitting Request'
        kit_filling_detail = Kitting::KitFillingDetail.find_by_id(returned_id)
        work_order_number = kit_filling_detail.kit_filling.kit_work_order.work_order.order_number rescue ""
        job_card_number = kit_filling_detail.kit_filling.kit_work_order.kit.customer_kit_part_number rescue ""
        job_card_description = kit_filling_detail.kit_filling.kit_work_order.kit.description rescue ""
        stage = kit_filling_detail.kit_filling.kit_work_order.work_order.stage rescue ""
        aircraft_serial_number = kit_filling_detail.kit_filling.kit_work_order.work_order.serial_number rescue ""
        detail_part_number =  kit_filling_detail.cup_part.part.part_number rescue ""
        quantity =  kit_filling_detail.filled_quantity rescue 0
        date_completed = kit_filling_detail.kit_filling.updated_at
        requestor = user_name
        self.create(:work_order => work_order_number,
                    :job_card_number => job_card_number,
                    :job_card_description => job_card_description,
                    :stage => stage,
                    :serial_number => aircraft_serial_number,
                    :part_number => detail_part_number,
                    :quantity => quantity,
                    :date_completed => date_completed,
                    :request_type => request_type,
                    :cust_no => curr_user,
                    :requestor => requestor)
      elsif request_type == 'Desk Request'
        order_part_detail = OrderPartDetail.find_by_id(returned_id)
        work_order_number = order_part_detail.order.order_number rescue ""
        job_card_number = order_part_detail.order.kit_part_number rescue ""
        job_card_description = Kitting::Kit.find_by_kit_number(order_part_detail.order.kit_part_number).description rescue ""
        stage =order_part_detail.order.station_name rescue ""
        aircraft_serial_number = order_part_detail.order.project_id rescue ""
        detail_part_number =  order_part_detail.part_number rescue ""
        quantity =  order_part_detail.quantity rescue 0
        date_completed = order_part_detail.shipment_date_time
        requestor = user_name
        self.create(:work_order => work_order_number,
                    :job_card_number => job_card_number,
                    :job_card_description => job_card_description,
                    :stage => stage,
                    :serial_number => aircraft_serial_number,
                    :part_number => detail_part_number,
                    :quantity => quantity,
                    :date_completed => date_completed,
                    :request_type => request_type,
                    :cust_no => curr_user,
                    :requestor => requestor)
      end
    end
  end
end
