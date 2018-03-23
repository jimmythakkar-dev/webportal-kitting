class AddColumnToTurnReport < ActiveRecord::Migration
  def change
    add_column :kitting_turn_report_details, :sub_kit_number, :string
  end
end
