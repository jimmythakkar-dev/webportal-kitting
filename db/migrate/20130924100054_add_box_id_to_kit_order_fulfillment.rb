class AddBoxIdToKitOrderFulfillment < ActiveRecord::Migration
  def change
    add_column :kitting_kit_order_fulfillments, :box_id, :string
  end
end
