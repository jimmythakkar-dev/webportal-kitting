class AddDefaultCribPartBinCenterToCustomerConfiguration < ActiveRecord::Migration
  def change
    add_column :customer_configurations, :default_crib_part_bin_center, :string
  end
end
