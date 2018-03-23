# This migration comes from kitting (originally 20130819075145)
class ChangeStatusDataTypeInKits < ActiveRecord::Migration
  def up
  	change_column :kits, :status, :integer
  end

  def down
  	change_column :kits, :status, :boolean
  end
end
