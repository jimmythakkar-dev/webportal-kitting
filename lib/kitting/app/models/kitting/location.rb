module Kitting
	class Location < ActiveRecord::Base
		self.table_name = "locations"
		attr_accessible :name, :customer_number
		has_many :kits
		has_many :kit_fillings
		has_many :kit_copies
		has_many :kit_work_orders
    has_many :order_part_details

		validates :name, presence: true, uniqueness: true
	end
end
