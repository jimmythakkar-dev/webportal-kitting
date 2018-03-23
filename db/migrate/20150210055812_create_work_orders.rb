class CreateWorkOrders < ActiveRecord::Migration
  def change
    create_table :work_orders do |t|
      t.string :order_number, null: false
      t.string :stage
      t.string :serial_number
      t.string :job_card_number, null: false
      t.string :created_by
      t.string :updated_by
      t.timestamps
    end
  end
end