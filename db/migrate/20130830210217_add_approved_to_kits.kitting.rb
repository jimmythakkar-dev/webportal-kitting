# This migration comes from kitting (originally 20130614060723)
class AddApprovedToKits < ActiveRecord::Migration
  def change
    add_column :kits, :approved, :boolean
  end
end
