# This migration comes from kitting (originally 20130819074401)
class RemoveLocationAndApprovedFromKit < ActiveRecord::Migration
  def up
  	remove_column :kits, :location_id
  	remove_column :kits, :approved
  end

  def down
  	add_column :kits, :location_id, :integer
  	add_column :kits, :approved, :boolean
  end
end
