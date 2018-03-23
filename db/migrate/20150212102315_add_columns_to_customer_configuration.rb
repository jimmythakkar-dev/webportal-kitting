class AddColumnsToCustomerConfiguration < ActiveRecord::Migration
  def change
    add_column :customer_configurations, :default_kit_bin_center, :string
    add_column :customer_configurations, :default_part_bin_center, :string
    add_column :customer_configurations, :kitting_type, :string
    add_column :customer_configurations, :invoicing_required, :boolean, :default => true
  end
end
