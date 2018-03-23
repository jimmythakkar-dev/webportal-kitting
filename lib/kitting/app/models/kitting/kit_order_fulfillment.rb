module Kitting
  class KitOrderFulfillment < ActiveRecord::Base
    attr_accessible :cust_name,:delivered,:filled_state, :kit_copy_number, :kit_filling_id, :kit_number, :location_name, :order_no_closed, :order_no_received, :scancode_closed, :scancode_received, :user_name, :box_id, :cust_no,:kit_work_order_id,:delivery_date,:delivery_point
    belongs_to :customer
    belongs_to :kit_filling
    belongs_to :kit_work_order
  end
end
