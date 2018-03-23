require 'spec_helper'

module Kitting
	describe TrackCopyVersion do
		it "has a valid factory" do
			FactoryGirl.create(:track_copy_version).should be_valid
		end	

		it "is invalid without kit_copy_id" do
			FactoryGirl.build(:track_copy_version, kit_copy_id: nil).should_not be_valid
		end

    it "is invalid without version" do
			FactoryGirl.build(:track_copy_version, version: nil).should_not be_valid
		end
	end
end