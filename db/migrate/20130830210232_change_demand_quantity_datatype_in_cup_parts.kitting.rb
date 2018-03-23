# This migration comes from kitting (originally 20130628072322)
class ChangeDemandQuantityDatatypeInCupParts < ActiveRecord::Migration
  def up
  	change_column :cup_parts, :demand_quantity, :string
  end

  def down
  	change_column :cup_parts, :demand_quantity, :integer
  end
end
