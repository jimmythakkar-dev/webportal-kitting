require 'spec_helper'

module Kitting
	describe Kit do
		it "has a valid factory" do
			FactoryGirl.create(:kit).should be_valid 
		end

		it "is invalid without kit number" do
			FactoryGirl.build(:kit, kit_number: nil).should_not be_valid 
		end

		it "is invalid without bin center" do
			FactoryGirl.build(:kit, bincenter: nil).should_not be_valid 
		end

		it "has a unique Kit number" do
			FactoryGirl.create(:kit, kit_number: "Kit-029540-121")
			FactoryGirl.build(:kit, kit_number: "Kit-029540-121").should_not be_valid
    end
    describe "Create Kit Object for creating cups" do
      before :each do
        @kit = FactoryGirl.create(:kit)
      end

      it 'Creates Cups based on the number of compartments' do
        @kit.create_cups(@kit, 8).should be_true
      end
    end

	end
end