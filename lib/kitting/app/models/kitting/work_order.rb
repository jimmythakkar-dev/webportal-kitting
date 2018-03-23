module Kitting
  class WorkOrder < ActiveRecord::Base
    self.table_name = 'work_orders'
    attr_accessible :order_number, :serial_number, :stage, :created_by, :updated_by
    has_many :kit_work_orders
    has_many :kits, :through => :kit_work_orders
    # validates :order_number, :uniqueness => true
    has_paper_trail
  end
end