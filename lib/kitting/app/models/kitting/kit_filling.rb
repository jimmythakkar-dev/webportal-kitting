module Kitting
  class KitFilling < ActiveRecord::Base
    self.table_name = "kit_fillings"
    attr_accessible :kit_copy_id, :location_id, :filled_state, :created_by, :flag, :customer_id, :received, :rbo_status, :kit_work_order_id
    belongs_to :kit_work_order
    belongs_to :kit_copy
    belongs_to :location
    belongs_to :customer
    belongs_to :order
    has_one :kit_order_fulfillment
    has_many :kit_filling_details, :dependent => :destroy
    has_many :kit_filling_history_reports, :dependent => :destroy
    has_paper_trail
    #validates :kit_copy_id, :location_id, presence: true

    def self.filled_state_display state
      if state == 0
        'Empty'
      elsif state == 1
        'Full'
      elsif state == 2
        'Partial'
      end
    end
  end
end