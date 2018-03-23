class AddCribColumnToOrderPartDetails < ActiveRecord::Migration
  def change
    add_column :order_part_details, :uom, :string
  end
end
