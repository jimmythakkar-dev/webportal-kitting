class AddKitWorkOrderToKitOrderFullfilment < ActiveRecord::Migration
  def change
    add_column :kitting_kit_order_fulfillments, :kit_work_order_id, :integer
  end
end
