class AddCustNoToKittingTurnReportDetail < ActiveRecord::Migration
  def change
  	add_column :kitting_turn_report_details, :cust_no, :string
  end
end
