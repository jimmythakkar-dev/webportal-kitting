module Kitting
  class KitWorkOrder < ActiveRecord::Base
    self.table_name = 'kit_work_orders'
    attr_accessible :due_date, :kit_id, :location_id, :work_order_id, :created_by
    belongs_to :kit
    belongs_to :work_order
    belongs_to :location
    has_many :kit_fillings,:dependent => :destroy
    has_paper_trail
  end
end
