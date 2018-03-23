require 'spec_helper'

module Kitting
	describe KitMediaType do
		it "has a valid factory" do
			FactoryGirl.create(:kit_media_type).should be_valid 
		end	

		it "is invalid without name" do
			FactoryGirl.build(:kit_media_type, name: nil).should_not be_valid 
		end

		it "is invalid without compartment" do
			FactoryGirl.build(:kit_media_type, compartment: nil).should_not be_valid
		end

		it "is invalid without kit_type" do
			FactoryGirl.build(:kit_media_type, kit_type: nil).should_not be_valid
		end

		it "has a unique name" do
			FactoryGirl.create(:kit_media_type, name: "Test KMT", compartment: "18", kit_type: "configurable")
			FactoryGirl.build(:kit_media_type, name: "Test KMT").should_not be_valid
		end
	end
end