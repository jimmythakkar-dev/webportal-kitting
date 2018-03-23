class RemoveJobCardNumberFromWorkOrders < ActiveRecord::Migration
  def up
    remove_column :work_orders, :job_card_number
  end

  def down
    add_column :work_orders, :job_card_number, :string
  end
end