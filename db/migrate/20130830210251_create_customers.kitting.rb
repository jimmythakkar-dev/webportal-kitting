# This migration comes from kitting (originally 20130826115105)
class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :cust_no
      t.string :cust_name
      t.string :user_name
      t.timestamps
		end
		add_index :customers, :cust_no
	end

	def self.down
		drop_table :customers
	end
end
