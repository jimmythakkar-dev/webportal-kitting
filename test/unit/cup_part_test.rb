# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path("../../test_helper", __FILE__)
module Kitting
  class CupPartTest < ActiveSupport::TestCase
    test "validate presence of_demand_quantity_fields" do
      cup_part=Kitting::CupPart.new(:id=>4000,:cup_id=> 10078,:part_id=> 10004,:demand_quantity=> nil,status: true, :created_at=> "2013-12-10 06:20:34", :updated_at=> "2013-12-10 06:27:55", :commit_id=> nil, :commit_status=> true, :uom=> "EA")
      assert !cup_part.save, "Saving cup_part without demand_quantity"
    end    

    test "validate presence of_part_id_fields" do
      cup_part=Kitting::CupPart.new(:id=>4000,:cup_id=> 10078,:demand_quantity=> "WL",status: true, :created_at=> "2013-12-10 06:20:34", :updated_at=> "2013-12-10 06:27:55", :commit_id=> nil, :commit_status=> true, :uom=> "EA")
      assert !cup_part.save, "Saving cup_part without demand_quantity"
    end
    
  end
end