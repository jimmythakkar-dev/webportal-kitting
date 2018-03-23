class RemoveCustomerCodeFromKits < ActiveRecord::Migration
  def up
    remove_column :kits, :customer_code
  end

  def down
    add_column :kits, :customer_code, :string
  end
end
