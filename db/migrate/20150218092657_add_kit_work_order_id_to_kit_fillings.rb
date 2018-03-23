class AddKitWorkOrderIdToKitFillings < ActiveRecord::Migration
  def change
    add_column :kit_fillings, :kit_work_order_id, :integer
  end
end
