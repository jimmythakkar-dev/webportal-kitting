class AddColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :auto_cancelled, :boolean, :default => false
  end
end
