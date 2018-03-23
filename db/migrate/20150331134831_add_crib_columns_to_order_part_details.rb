class AddCribColumnsToOrderPartDetails < ActiveRecord::Migration
  def change
    add_column :order_part_details, :bin_location, :string
    add_column :order_part_details, :pack_id, :string
    add_column :order_part_details, :location_id, :integer
    add_column :order_part_details, :received_flag, :boolean, :default => false
  end
end
