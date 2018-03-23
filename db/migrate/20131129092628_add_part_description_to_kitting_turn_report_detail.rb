class AddPartDescriptionToKittingTurnReportDetail < ActiveRecord::Migration
  def change
  	add_column :kitting_turn_report_details , :part_description, :string, :after => :part_number
  end
end
