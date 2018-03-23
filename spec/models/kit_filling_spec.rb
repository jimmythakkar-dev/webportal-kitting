require 'spec_helper'
module Kitting
	describe KitFilling do
		it "has a valid factory" do
			FactoryGirl.create(:kit_filling).should be_valid 
		end


		describe "Match Filled State by passed value" do
			before :each do
				@empty_state = FactoryGirl.build(:kit_filling, filled_state: 0)
				@full_state = FactoryGirl.build(:kit_filling, filled_state: 1)
				@partial_state = FactoryGirl.build(:kit_filling, filled_state: 2)
			end

			context "Comparing Filled State" do
				it "Returns Correct State" do
					KitFilling.filled_state_display(@empty_state.filled_state).should == 'Empty'
					KitFilling.filled_state_display(@full_state.filled_state).should == 'Full'
					KitFilling.filled_state_display(@partial_state.filled_state).should == 'Partial'
				end

				it "Returns InCorrect State" do
					KitFilling.filled_state_display(@empty_state.filled_state).should_not == 'Partial'
					KitFilling.filled_state_display(@full_state.filled_state).should_not == 'Empty'
					KitFilling.filled_state_display(@partial_state.filled_state).should_not == 'Full'
				end
			end	
		end	
	end
end