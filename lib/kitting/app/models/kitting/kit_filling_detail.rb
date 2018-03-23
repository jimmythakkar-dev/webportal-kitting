module Kitting
  class KitFillingDetail < ActiveRecord::Base
    self.table_name = "kit_filling_details"
    attr_accessible :cup_part_id, :filled_quantity, :kit_filling_id, :filled_state,:pack_id, :bin_location, :receive_flag, :receive_type
    after_create :add_pack_id
    has_paper_trail
    belongs_to :cup_part
    belongs_to :kit_filling
    has_one :order_part_detail
    def add_pack_id
      if self.kit_filling.kit_copy.nil?
        cup_parts = self.kit_filling.kit_work_order.kit.cups.sort.map(&:cup_parts).flatten
        index_value = cup_parts.index {|cup_part| cup_part.id == self.cup_part_id}
        self.update_attribute(:pack_id, "#{self.kit_filling_id}-#{index_value+1}") if index_value.present?
      end
      return true
    end
  end
end