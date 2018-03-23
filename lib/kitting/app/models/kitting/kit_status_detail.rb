module Kitting
  class KitStatusDetail < ActiveRecord::Base
    attr_accessible :kit_copy_id, :kit_id, :reason, :updated_by
    belongs_to :kit
    belongs_to :kit_copy
  end
end
