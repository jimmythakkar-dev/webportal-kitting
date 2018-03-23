# This migration comes from kitting (originally 20130625075205)
class RenameFlagToStatusInKit < ActiveRecord::Migration
  def up
  	rename_column :kits, :flag, :status
  end

  def down
  	rename_column :kits, :status, :flag
  end
end
