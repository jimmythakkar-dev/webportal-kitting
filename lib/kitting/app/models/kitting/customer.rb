module Kitting
  class Customer < ActiveRecord::Base
    self.table_name = "customers"
    attr_accessible :cust_name, :cust_no, :user_name,:user_level,:user_type,:accounts, :vendor_no, :partner_no, :upload_configuration
    has_many :kits, :dependent => :destroy
    has_many :kit_copies, :dependent => :destroy
    has_many :kit_media_types , :dependent => :destroy
    has_many :kit_fillings, :dependent => :destroy
    #has_many :parts, :dependent => :destroy
    #has_many :kit_uploads , :dependent => :destroy
    has_many :kit_bom_bulk_operations, :dependent => :destroy
    has_many :kit_order_fulfillments , :dependent => :destroy
  end
end
