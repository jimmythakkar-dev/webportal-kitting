module Kitting
  class KitFillingHistoryReport < ActiveRecord::Base
     self.table_name = "kit_filling_history_reports"
     belongs_to :kit_filling
     attr_accessible :kit_number, :kit_copy_number, :cup_no, :part_number, :demand_qty, :filled_qty, :created_by, :filling_date,:customer_number, :kit_filling_id, :cup_part_id, :cup_part_status, :cup_part_commit_status,:kit_work_order_id
  end
end
