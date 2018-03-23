class AddActualQtyToKitFillingHistoryReport < ActiveRecord::Migration
  def change
    add_column :kit_filling_history_reports , :actual_qty, :string, :after => :cup_part_commit_status
  end
end
