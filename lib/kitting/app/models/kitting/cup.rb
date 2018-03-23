module Kitting
  class Cup < ActiveRecord::Base
    self.table_name = "cups"
    attr_accessible :kit_id, :status, :ref1, :ref2 , :ref3, :commit_status, :commit_id,:cup_number,:cup_dimension
    belongs_to :kit
    has_many :cup_parts
    has_many :parts, :through => :cup_parts
    validates :kit_id, :presence => true
    has_paper_trail

    def check_in_contract_status key
      self.send(key.to_sym).where(:status => true,:in_contract => false).count == 0
    end
  end
end