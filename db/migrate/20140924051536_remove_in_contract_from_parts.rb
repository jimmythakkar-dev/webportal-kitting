class RemoveInContractFromParts < ActiveRecord::Migration
  def up
    remove_column :parts, :in_contract
  end

  def down
    add_column :parts, :in_contract, :boolean, :default => true
  end
end