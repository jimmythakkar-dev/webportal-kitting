# This migration comes from kitting (originally 20130701072858)
class RenameColumnFromActionToFilledState < ActiveRecord::Migration
  def up
    rename_column :kit_fillings, :action, :filled_state
  end

  def down
    rename_column :kit_fillings, :filled_state, :action
  end
end
