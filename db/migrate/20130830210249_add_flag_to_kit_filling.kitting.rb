# This migration comes from kitting (originally 20130822133815)
class AddFlagToKitFilling < ActiveRecord::Migration
  def change
    add_column :kit_fillings, :flag, :boolean
  end
end
