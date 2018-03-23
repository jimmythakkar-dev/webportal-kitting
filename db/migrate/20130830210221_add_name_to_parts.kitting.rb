# This migration comes from kitting (originally 20130618093250)
class AddNameToParts < ActiveRecord::Migration
  def change
    add_column :parts, :name, :string
  end
end
