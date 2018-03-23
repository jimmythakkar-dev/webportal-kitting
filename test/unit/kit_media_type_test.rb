# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class KitMediaTypeTest < ActiveSupport::TestCase
    test "validate presence of name fields" do
      kit_media_type = Kitting::KitMediaType.new(:id=> 90000, :compartment=> 1000, :kit_type=> "binder",:compartment_layout=> "{\"1\":\"\"}",:customer_number=> "029540")
      assert !kit_media_type.save, "Saving kit media type without name"
    end
  end
end