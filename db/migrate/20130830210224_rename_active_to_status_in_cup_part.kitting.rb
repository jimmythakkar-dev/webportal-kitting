# This migration comes from kitting (originally 20130620050750)
class RenameActiveToStatusInCupPart < ActiveRecord::Migration
  def up
  	rename_column :cup_parts, :action, :status
  	change_column :cup_parts, :status, :boolean, :default => 1
  end

  def down
  	rename_column :cup_parts, :status, :action
  	change_column :cup_parts, :action, :interger
  end
end
