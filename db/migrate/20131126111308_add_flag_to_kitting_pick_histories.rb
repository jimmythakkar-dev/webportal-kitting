class AddFlagToKittingPickHistories < ActiveRecord::Migration
  def change
    add_column :kitting_pick_histories, :flag, :boolean, :default => false
  end
end
