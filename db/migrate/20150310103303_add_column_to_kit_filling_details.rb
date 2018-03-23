class AddColumnToKitFillingDetails < ActiveRecord::Migration
  def change
    add_column :kit_filling_details, :receive_flag, :boolean, default: false
    add_column :kit_filling_details, :receive_type, :string
  end
end
