# This migration comes from kitting (originally 20130704062334)
class AddCustomerNumberAndCustomerCustomerNumberToKitMediaType < ActiveRecord::Migration
  def change
    add_column :kit_media_types, :customer_number, :string
    add_column :kit_media_types, :customer_name, :string
  end
end
