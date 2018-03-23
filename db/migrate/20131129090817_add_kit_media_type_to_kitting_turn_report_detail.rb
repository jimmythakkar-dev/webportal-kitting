class AddKitMediaTypeToKittingTurnReportDetail < ActiveRecord::Migration
  def change
  	add_column :kitting_turn_report_details , :kit_media_type, :string, :after => :kit_description	
  end
end
