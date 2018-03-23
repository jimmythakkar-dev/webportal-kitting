# This migration comes from kitting (originally 20130704062148)
class AddCustomerNumberAndCustomerCustomerNumberToPart < ActiveRecord::Migration
  def change
    add_column :parts, :customer_number, :string
    add_column :parts, :customer_name, :string
  end
end
