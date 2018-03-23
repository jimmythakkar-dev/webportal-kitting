# This migration comes from kitting (originally 20130628061133)
class AddDetailsToKitFilling < ActiveRecord::Migration
  def change
    add_column :kit_fillings, :action, :integer
    add_column :kit_fillings, :created_by, :string
  end
end
