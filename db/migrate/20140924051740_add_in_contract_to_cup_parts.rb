class AddInContractToCupParts < ActiveRecord::Migration
  def change
    add_column :cup_parts, :in_contract, :boolean, :default => true
  end
end
