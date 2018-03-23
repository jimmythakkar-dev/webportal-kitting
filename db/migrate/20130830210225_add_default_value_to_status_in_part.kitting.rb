# This migration comes from kitting (originally 20130620053157)
class AddDefaultValueToStatusInPart < ActiveRecord::Migration
  def change
  	change_column :parts, :status, :boolean, default: 1
  end
end
