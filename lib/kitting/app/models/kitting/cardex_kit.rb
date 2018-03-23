module Kitting
  class CardexKit < ActiveRecord::Base
    self.table_name = "cardex_kits"
    attr_accessible :kit_html_layout,:kit_media_type_id, :kit_number, :created_by, :updated_by,:box_number,:parent_kit_id
    belongs_to :kit_media_type
    has_many :sub_kits, :foreign_key => "parent_kit_id",:class_name => "Kitting::CardexKit", :dependent => :destroy
    validates :kit_number, :presence => true
    validates :kit_media_type_id, :presence => true
    def is_mmt?
      self.kit_media_type.kit_type == "multi-media-type"
    end

    def mmt_kit
      self.class.find_by_id(self.parent_kit_id)
    end
  end
end