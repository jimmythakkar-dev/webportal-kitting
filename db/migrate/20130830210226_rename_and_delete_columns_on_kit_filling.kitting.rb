# This migration comes from kitting (originally 20130625062648)
class RenameAndDeleteColumnsOnKitFilling < ActiveRecord::Migration
  def up
    rename_column :kit_fillings, :cup_id, :cup_part_id
    remove_column :kit_fillings, :part_id
  end

  def down
    rename_column :kit_fillings, :cup_part_id, :cup_id
    add_column :kit_fillings, :part_id, :string
  end
end
