module Kitting
  class KitMediaType < ActiveRecord::Base
    self.table_name = "kit_media_types"
    attr_accessible :compartment, :description, :kit_type, :name, :compartment_layout, :customer_id,:customer_number
    has_many :kits, :dependent => :destroy
    has_many :cardex_kits
    belongs_to :customer
    validates :name, :compartment, :kit_type, :presence => true
    validates :name, uniqueness: { :case_sensitive => false, :scope => :customer_number}
    alias_method :to_i, :id
  end
end