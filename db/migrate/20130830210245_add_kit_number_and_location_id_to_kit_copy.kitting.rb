# This migration comes from kitting (originally 20130819070025)
class AddKitNumberAndLocationIdToKitCopy < ActiveRecord::Migration
  def change
  	add_column :kit_copies, :kit_version_number, :string
    add_column :kit_copies, :location_id, :integer
    add_column :kit_copies, :status, :integer
    rename_column :kit_copies, :from, :kit_id
  end
end
