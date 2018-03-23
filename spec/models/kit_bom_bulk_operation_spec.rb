require 'spec_helper'
module Kitting
  describe KitBomBulkOperation do
    it "has a valid factory" do
			FactoryGirl.create(:kit_bom_bulk_operation).should be_valid
		end

#		it "is invalid without file_path" do
#			FactoryGirl.build(:kit_bom_bulk_operation, file_path: nil).should_not be_valid
#		end

		it "has a unique file_path" do
			FactoryGirl.create(:kit_bom_bulk_operation, file_path: "Test.csv")
			FactoryGirl.build(:kit_bom_bulk_operation, file_path: "Test.csv").should_not be_valid
		end
  end
end
