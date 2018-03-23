require 'spec_helper'

module Kitting
	describe Part do
		it "has a valid factory" do
			FactoryGirl.create(:part).should be_valid 
		end

		it "is invalid without part number" do
			FactoryGirl.build(:part, part_number: nil).should_not be_valid 
		end

		it "has a unique part number" do
			FactoryGirl.create(:part, part_number: "Test Part")
			FactoryGirl.build(:part, part_number: "Test Part").should_not be_valid
		end
	end
end