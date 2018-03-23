require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class PartTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end

    #fixtures :parts

    test "validate presence of not null fields" do
      part = Kitting::Part.new
      assert !part.save, "Saving part without data"

      part = Kitting::Part.new(:part_number => "abc", :created_at => "2013-11-23 12:45:38", :updated_at => "2013-11-23 12:45:38")
      assert !part.save, "Saving part without id"

      part = Kitting::Part.new(:id => "1", :created_at => "2013-11-23 12:45:38", :updated_at => "2013-11-23 12:45:38")
      assert !part.save, "Saving part without part number"

      part = Kitting::Part.new(:id => "1", :part_number => "abc", :updated_at => "2013-11-23 12:45:38")
      assert !part.save, "Saving part without created at date"

      part = Kitting::Part.new(:id => "1", :part_number => "abc", :created_at => "2013-11-23 12:45:38")
      assert !part.save, "Saving part without updated at date"
    end    
    

#    test "validate uniquiness of part number" do
#      part = Kitting::Part.new(:id => parts(:general).id,
#        :part_number => parts(:general).part_number,
#        :created_at => parts(:general).created_at,
#        :updated_at => parts(:general).updated_at
#      )
#      assert !part.save, "Saved part with duplicate part number"
#      assert_equal "has already been taken", part.errors[:part_number].join(', ')
#    end

    test "validate uniquiness of part number" do      
      part = Kitting::Part.new(:part_number => "MS20426AD3-4")
      part.valid?
      assert_equal "has already been taken", part.errors[:part_number].join(', '), "Duplicate part number"
    end

    test "validate numeric data type" do
      part = Kitting::Part.new(:id => "1", :part_number => "abc", :created_at => "2013-11-23 12:45:38", :updated_at => "2013-11-23 12:45:38", :customer_id => "acx", :commit_id => "ab")
      part.valid?
      assert_equal "is not a number", part.errors[:customer_id].join(', '), "Non-numeric value entered for customer_id"
      assert_equal "is not a number", part.errors[:commit_id].join(', '), "Non-numeric value entered for customer_id"
    end
  end
end
