# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class KitCopyTest < ActiveSupport::TestCase
    test "validate presence of kit_id fields" do
      kit_copy= Kitting::KitCopy.new(:id=> 10008,:kit_version_number=> "KIT-029540-10010-1", :location_id=> 10005, :status=> 1)
      assert !kit_copy.save, "Saving kit copy without kit_id"
    end

    test "validate presence of location_id fields" do
      kit_copy= Kitting::KitCopy.new(:id=> 10008, :kit_id=> 10010,:kit_version_number=> "KIT-029540-10010-1", :status=> 1)
      assert !kit_copy.save, "Saving kit copy without location_id"
    end

    test "validate presence of kit_version_number fields" do
      kit_copy= Kitting::KitCopy.new(:id=> 10008, :kit_id=> 10010, :location_id=> 10005, :status=> 1)
      assert !kit_copy.save, "Saving kit copy without kit_version_number"
    end
    
  end
end