module Kitting
  class CustomerConfigurations < ActiveRecord::Base
    self.table_name = "customer_configurations"
    attr_accessible :cust_name, :cust_no, :multiple_part, :non_contract_part, :prevent_kit_copy, :updated_by, :default_kit_bin_center, :default_part_bin_center, :kitting_type, :invoicing_required, :default_crib_part_bin_center
    has_paper_trail
    validates :cust_no, :presence => true, :uniqueness => true
  end
end
