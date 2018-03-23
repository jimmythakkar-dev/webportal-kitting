module Kitting
  class TurnReportDetail < ActiveRecord::Base
    attr_accessible :cup_no, :kit_description, :kit_media_type, :part_description , :kit_number, :part_number, :turns_copy1, :turns_copy10, :turns_copy2, :turns_copy3, :turns_copy4, :turns_copy5, :turns_copy6, :turns_copy7, :turns_copy8, :turns_copy9, :cust_no,  :sub_kit_number
  end
end
