require File.expand_path("../../../test_helper", __FILE__)

module Kitting
  class PartTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end

    test "validate part number" do
      Kitting::Part.new
      assert !Kitting::Part.save
    end
  end
end
