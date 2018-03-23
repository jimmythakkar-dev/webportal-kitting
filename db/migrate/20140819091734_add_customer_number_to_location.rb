class AddCustomerNumberToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :customer_number, :string
  end
end
