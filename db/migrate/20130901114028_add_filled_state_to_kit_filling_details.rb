class AddFilledStateToKitFillingDetails < ActiveRecord::Migration
  def change
    add_column :kit_filling_details, :filled_state, :string
  end
end
