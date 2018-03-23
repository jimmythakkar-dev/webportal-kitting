module Kitting
	class KitVersionTrack < ActiveRecord::Base
		self.table_name = "kit_version_tracks"
		attr_accessible :cups, :cup_parts, :kit,:kit_id,:kit_number, :kit_version
		has_paper_trail
	end
end