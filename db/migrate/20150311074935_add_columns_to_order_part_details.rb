class AddColumnsToOrderPartDetails < ActiveRecord::Migration
  def change
    add_column :order_part_details, :filled_state, :string
    add_column :order_part_details, :cancellation_date, :datetime
    add_column :order_part_details, :kit_filling_detail_id, :integer
  end
end
