module Kitting
	class TrackCopyVersion < ActiveRecord::Base
		self.table_name = "track_copy_versions"
		has_paper_trail
		has_one :kit_copy
		attr_accessible :filled_version, :picked_version, :version,:kit_copy_id
		validates :kit_copy_id, presence: true
		validates :version, presence: true
	end
end
