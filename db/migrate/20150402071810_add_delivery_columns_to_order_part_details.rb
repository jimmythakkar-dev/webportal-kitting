class AddDeliveryColumnsToOrderPartDetails < ActiveRecord::Migration
  def change
    add_column :order_part_details, :delivery_point, :string
    add_column :order_part_details, :delivery_date, :datetime
    add_column :order_part_details, :delivered, :boolean, :default => false
  end
end