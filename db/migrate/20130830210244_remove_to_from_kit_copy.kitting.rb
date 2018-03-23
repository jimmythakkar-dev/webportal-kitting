# This migration comes from kitting (originally 20130819065231)
class RemoveToFromKitCopy < ActiveRecord::Migration
  def up
  	remove_column :kit_copies, :to
  end

  def down
  	add_column :kit_copies, :to, :integer
  end
end
