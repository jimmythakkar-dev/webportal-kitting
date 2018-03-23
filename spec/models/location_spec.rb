require 'spec_helper'

module Kitting
	describe Location do
		it "has a valid factory" do
			FactoryGirl.create(:location).should be_valid
		end	

		it "is invalid without name" do
			FactoryGirl.build(:location, name: nil).should_not be_valid
		end

		it "has a unique name" do
			FactoryGirl.create(:location, name: "Test Location")
			FactoryGirl.build(:location, name: "Test Location").should_not be_valid
		end
	end
end