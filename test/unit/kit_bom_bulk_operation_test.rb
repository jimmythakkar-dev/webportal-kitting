# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.expand_path("../../test_helper", __FILE__)
module Kitting
  class KitBomBulkOperationTest < ActiveSupport::TestCase
    test "validate uniqueness of file_path fields" do
      kit_bom_bulk_operation = Kitting::KitBomBulkOperation.new(:id=> 10001, :operation_type=> "BOM DOWNLOAD", :file_path=> "KIT-029540-10653_10001.csv", :status=> "PROCESSING", :customer_id=> 10001, :kit_number=> "KIT-029540-10653", :bin_center=> nil, :part_number=> nil, :new_part_number=> nil, :old_part_number=> nil, :is_downloaded=> false, :created_at=> "2013-12-11 16:05:37", :updated_at=> "2013-12-11 16:05:37")
      assert !kit_bom_bulk_operation.save, "Saving kit bom bulk operation without file_path"
    end
  end
end