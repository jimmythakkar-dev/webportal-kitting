class AddUserDetailsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :user_level, :string
    add_column :customers, :user_type, :string
  end
end
