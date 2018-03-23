# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class CupTest < ActiveSupport::TestCase
    test "validate presence of not null fields" do
      cups = Kitting::Cup.new
      assert !cups.save, "Saving cups without data"

      cups.kit_id =nil
      assert !cups.save, "Saving cups without kit_id"

      cups = Kitting::Cup.new(:id => "4000",:commit_status=> true,:cup_number=>1, :created_at => "2013-12-10 06:19:45", :updated_at => "2013-12-10 06:19:45")
      assert !cups.save, "Saving cups without kit_id"
      
#      cups = Kitting::Cup.new(:id => "4000",:commit_status=> true,:kit_id=> 10007, :created_at => "2013-12-10 06:19:45", :updated_at => "2013-12-10 06:19:45")
#      assert !cups.save, "Saving cups without cup_number"
    end
  end
end

