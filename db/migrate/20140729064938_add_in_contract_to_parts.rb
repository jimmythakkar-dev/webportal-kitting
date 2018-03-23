class AddInContractToParts < ActiveRecord::Migration
  def change
    add_column :parts, :in_contract, :boolean, :default => true
  end
end
