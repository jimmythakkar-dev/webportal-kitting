class CreateKitWorkOrders < ActiveRecord::Migration
  def change
    create_table :kit_work_orders do |t|
      t.integer :kit_id
      t.integer :work_order_id
      t.date :due_date
      t.integer :location_id
      t.string :created_by

      t.timestamps
    end
  end
end
