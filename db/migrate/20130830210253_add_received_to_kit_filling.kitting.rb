# This migration comes from kitting (originally 20130829140100)
class AddReceivedToKitFilling < ActiveRecord::Migration
  def change
    add_column :kit_fillings, :received, :string
  end
end
