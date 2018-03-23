module Kitting
	class CupPart < ActiveRecord::Base
		self.table_name = "cup_parts"
    attr_accessor :box_number
		attr_accessible :cup_id, :part_id, :status, :demand_quantity, :uom, :commit_status, :commit_id,:in_contract, :box_number
		belongs_to :cup
		belongs_to :part
		has_many :kit_filling_details
		has_paper_trail

		#validates :cup_id, uniqueness: { scope: :part_id }
		validates :demand_quantity, presence: { message: "Quantity Cannot be empty. Please Enter Quantity"}
		validates :part_id, presence: true
	end
end
