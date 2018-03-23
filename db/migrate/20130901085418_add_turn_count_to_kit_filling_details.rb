class AddTurnCountToKitFillingDetails < ActiveRecord::Migration
  def change
    add_column :kit_filling_details, :turn_count, :integer, :default => 0
  end
end
