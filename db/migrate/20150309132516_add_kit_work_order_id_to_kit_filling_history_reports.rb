class AddKitWorkOrderIdToKitFillingHistoryReports < ActiveRecord::Migration
  def change
    add_column :kit_filling_history_reports, :kit_work_order_id, :integer
  end
end
