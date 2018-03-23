class AddCribPartToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :due_date, :date
    add_column :orders, :kit_filling_id, :integer
    add_column :orders, :cancellation_date, :datetime
  end
end
