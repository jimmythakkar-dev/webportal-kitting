class AddBinLocationToKitFillingDetails < ActiveRecord::Migration
  def change
    add_column :kit_filling_details, :bin_location, :string
  end
end
