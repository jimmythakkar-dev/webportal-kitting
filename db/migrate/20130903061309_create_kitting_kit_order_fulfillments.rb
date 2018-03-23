class CreateKittingKitOrderFulfillments < ActiveRecord::Migration
  def change
    create_table :kitting_kit_order_fulfillments do |t|
      t.integer :kit_filling_id
      t.string :kit_copy_number
      t.string :kit_number
      t.string :user_name
      t.string :cust_name
      t.integer :filled_state
      t.string :location_name
      t.string :order_no_closed
      t.string :scancode_closed
      t.text :order_no_received
      t.text :scancode_received

      t.timestamps
    end
  end
end
