class AddAccountsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :accounts, :text
  end
end
