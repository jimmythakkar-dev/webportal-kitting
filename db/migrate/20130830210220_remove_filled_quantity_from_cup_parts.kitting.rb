# This migration comes from kitting (originally 20130618090850)
class RemoveFilledQuantityFromCupParts < ActiveRecord::Migration
  def up
    remove_column :cup_parts, :filled_quantity
  end

  def down
    add_column :cup_parts, :filled_quantity, :number
  end
end
