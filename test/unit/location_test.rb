require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class LocationTest < ActiveSupport::TestCase

    test "should not save without a name for location" do
        location = Location.new
        assert !location.save, "Save the location without name"
    end

    test "should have a unique name for location" do
      location1 = Location.new(:name => "blah")
      location1.save
      location2 = Location.new(:name => "blah")
      location2.valid?
      assert_equal "has already been taken", location2.errors[:name].join(', '), "Duplicate location name"
    end
  end
end

