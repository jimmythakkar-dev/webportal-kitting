class AddCustNoToKittingKitOrderFulfillment < ActiveRecord::Migration
  def change
    add_column :kitting_kit_order_fulfillments, :cust_no, :string
  end
end
