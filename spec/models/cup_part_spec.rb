require 'spec_helper'

module Kitting
	describe CupPart do
		it "has a valid factory" do
			FactoryGirl.create(:cup_part).should be_valid
		end	

#		it "is invalid without cup_id" do
#			FactoryGirl.build(:cup_part, cup_id: nil).should_not be_valid
#		end

    it "is invalid without part_id" do
			FactoryGirl.build(:cup_part, part_id: nil).should_not be_valid
		end

    it "is invalid without demand_quantity" do
			FactoryGirl.build(:cup_part, demand_quantity: nil).should_not be_valid
		end

#		it "has a unique cup_id" do
#			FactoryGirl.create(:cup_part, cup_id: 1234)
#			FactoryGirl.build(:cup_part, cup_id: 1234).should_not be_valid
#		end
	end
end