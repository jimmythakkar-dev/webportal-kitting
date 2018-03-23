class AddPackIdToKitFillingDetails < ActiveRecord::Migration
  def change
    add_column :kit_filling_details, :pack_id, :string
  end
end
