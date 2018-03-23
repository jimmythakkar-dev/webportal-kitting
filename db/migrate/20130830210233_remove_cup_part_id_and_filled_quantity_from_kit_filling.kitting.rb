# This migration comes from kitting (originally 20130701071933)
class RemoveCupPartIdAndFilledQuantityFromKitFilling < ActiveRecord::Migration
  def up
    remove_column :kit_fillings, :cup_part_id
    remove_column :kit_fillings, :filled_quantity
  end

  def down
    add_column :kit_fillings, :filled_quantity, :integer
    add_column :kit_fillings, :cup_part_id, :integer
  end
end
