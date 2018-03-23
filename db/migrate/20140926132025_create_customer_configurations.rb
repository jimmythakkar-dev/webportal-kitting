class CreateCustomerConfigurations < ActiveRecord::Migration
  def self.up
    create_table :customer_configurations do |t|
      t.string :cust_no
      t.string :cust_name
      t.boolean :non_contract_part,:default => false
      t.boolean :prevent_kit_copy,:default => false
      t.boolean :multiple_part,:default => false
      t.string :updated_by
      t.timestamps
    end
    add_index "customer_configurations", ["cust_no"], :name => "index_cust_config_cust_no"
  end

  def self.down
    if index_exists?(:customer_configurations, [:cust_no])
      remove_index :customer_configurations, [:cust_no]
    end
    drop_table :customer_configurations
  end
end
