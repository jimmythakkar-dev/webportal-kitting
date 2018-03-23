class RemoveAgustaConstraint < ActiveRecord::Migration
  def up
    change_column :orders, :order_number, :string, :null => true
  end

  def down
    change_column :orders, :order_number, :string, :null => false
  end

end
