class ChangeQuantityToStringInOrderPartDetails < ActiveRecord::Migration
  def up
    add_column :order_part_details, :temp_quantity, :string
    OrderPartDetail.update_all("temp_quantity = quantity")
    remove_column :order_part_details, :quantity
    rename_column :order_part_details, :temp_quantity, :quantity
  end

  def down
    change_column :order_part_details, :quantity, :integer
  end
end
