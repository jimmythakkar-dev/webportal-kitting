class AddVendorNoAndPartnerNoToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :vendor_no, :string
    add_column :customers, :partner_no, :string
  end
end
