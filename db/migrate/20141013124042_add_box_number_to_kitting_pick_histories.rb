class AddBoxNumberToKittingPickHistories < ActiveRecord::Migration
  def change
    add_column :kitting_pick_histories, :box_number, :integer
  end
end
