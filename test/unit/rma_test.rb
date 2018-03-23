require File.expand_path("../../test_helper", __FILE__)

class RmaTest < ActiveSupport::TestCase

  test "validate image path" do
    path = Rma.image_path
    assert_not_nil path, "Returns nil value"
  end
end