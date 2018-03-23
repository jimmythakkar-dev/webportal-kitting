class AddPreventKitCopyToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :prevent_kit_copy, :boolean, :default => false
  end
end
