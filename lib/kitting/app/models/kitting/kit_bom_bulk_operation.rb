module Kitting
	class KitBomBulkOperation < ActiveRecord::Base
		self.table_name = "kit_bom_bulk_operations"
		belongs_to :customer
		attr_accessible :bin_center, :file_path, :status, :is_downloaded, :kit_number, :new_part_number, :old_part_number, :operation_type, :part_number
		validates :file_path, :uniqueness => true
	end
end
