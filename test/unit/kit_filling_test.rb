# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class KitFillingTest < ActiveSupport::TestCase 
    test "validate presence of kit_copy_id fields" do
      kit_filling= Kitting::KitFilling.new(:id=> 10086, :location_id=> 10003,:filled_state=> 1)
      assert !kit_filling.save, "Saving kit filling without kit_copy_id"
    end

    test "validate presence of location_id fields" do
      kit_filling= Kitting::KitFilling.new(:id=> 10086, :kit_copy_id=> 10000,:filled_state=> 1)
      assert !kit_filling.save, "Saving kit filling without location_id"
    end

  end
end