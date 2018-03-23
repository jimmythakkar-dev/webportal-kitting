module Kitting
	class KitCopy < ActiveRecord::Base
		self.table_name = "kit_copies"
		attr_accessible :kit_id, :location_id, :kit_version_number, :status, :customer_id,:version_status, :rfid_number
		belongs_to :kit
		belongs_to :location
		belongs_to :customer
		belongs_to :track_copy_version, :dependent => :destroy
		has_many :kit_fillings, :dependent => :destroy
    has_many :kit_status_details
    #validates :kit_id, :location_id, :kit_version_number, presence: true
    #validates :rfid_number, presence: true, uniqueness: true
	end
end
