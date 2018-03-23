class AddCustNoToReturnedPartDetail < ActiveRecord::Migration
  def change
    add_column :returned_part_details, :cust_no, :string
  end
end
