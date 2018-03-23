module Kitting
	class PickHistory < ActiveRecord::Base
		attr_accessible :bincenter, :binlocation, :created_by, :cup_id, :kit_copy_id, :kit_number, :ordernolist, :part_number, :updated_by, :kit_filling_id, :flag, :box_number
	end
end
