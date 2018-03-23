# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)

module Kitting
  class KitTest < ActiveSupport::TestCase
    test "validate presence of kit_media_type_id fields" do
      kit = Kitting::Kit.new(:id=> 10007, :kit_media_type_id=> nil, :kit_number=> "KIT-029540-10006", :status=> 1, :created_at=> "2013-12-10 06:19:45", :updated_at=> "2013-12-10 06:27:55", :cust_no=> "029540", :bincenter=> "1962", :customer_id=> 10001, :notes=> "test", :description=> "test", :commit_id=> nil, :commit_status=> true, :current_version=> "1", :edit_status=> "FK", :part_bincenter=> "1962", :created_by=> 10001, :updated_by=> 10001)
      assert !kit.save, "Saving kit without kit_media_type_id"
    end
    
    test "validate uniqueness of kit_number fields" do
      kit = Kitting::Kit.new(:id=> 10007, :kit_media_type_id=> 10011, :kit_number=> "KIT-029540-10006", :status=> 1, :created_at=> "2013-12-10 06:19:45", :updated_at=> "2013-12-10 06:27:55", :cust_no=> "029540", :bincenter=> "1962", :customer_id=> 10001, :notes=> "test", :description=> "test", :commit_id=> nil, :commit_status=> true, :current_version=> "1", :edit_status=> "FK", :part_bincenter=> "1962", :created_by=> 10001, :updated_by=> 10001)
      assert !kit.save, "Saving kit already exist kit_number"
    end
  end
end