class AddKitFillingIdToKittingPickHistories < ActiveRecord::Migration
  def change
    add_column :kitting_pick_histories, :kit_filling_id, :integer
  end
end
