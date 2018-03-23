class AddColumnsToKitOrderFulfillment < ActiveRecord::Migration
  def change
    add_column :kitting_kit_order_fulfillments, :delivery_point, :string
    add_column :kitting_kit_order_fulfillments, :delivery_date, :datetime
    add_column :kitting_kit_order_fulfillments, :delivered, :boolean, :default => false
  end
end