# This migration comes from kitting (originally 20130821122405)
class RenameKitIdToKitCopyIdInKitFilling < ActiveRecord::Migration
  def up
  	rename_column :kit_fillings, :kit_id, :kit_copy_id
  end

  def down
  	rename_column :kit_fillings, :kit_copy_id, :kit_id
  end
end
