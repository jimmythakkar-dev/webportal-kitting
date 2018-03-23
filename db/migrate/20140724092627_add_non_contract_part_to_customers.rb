class AddNonContractPartToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :non_contract_part, :boolean, :default => false
  end
end
